library(keras3)
library(tensorflow)
library(tidyverse)
library(keras3)
library(tensorflow)

# -------------------------
# Data
# -------------------------
load('slides/ai_models/genodata_5k.Rd')

orig_pheno <- readr::read_csv(
  "slides/ai_models/autosomal_5k_phenos.csv",
  col_names = TRUE
) |>
  dplyr::select(-1)

geno_scaled <- as.matrix(orig_geno) / 2

input_dim <- ncol(geno_scaled)
latent_dim <- 2
intermediate_dim <- 256

# -------------------------
# Sampling layer
# -------------------------
sampling_layer <- new_layer_class(
  classname = "Sampling",
  
  call = function(inputs, mask = NULL) {
    z_mean <- inputs[[1]]
    z_log_var <- inputs[[2]]
    
    epsilon <- tf$random$normal(tf$shape(z_mean))
    z_mean + tf$exp(0.5 * z_log_var) * epsilon
  }
)

# -------------------------
# Encoder
# -------------------------
encoder_inputs <- layer_input(shape = input_dim)

x <- encoder_inputs |>
  layer_dense(intermediate_dim, activation = "relu")

z_mean <- x |> layer_dense(latent_dim)
z_log_var <- x |> layer_dense(latent_dim)

z <- sampling_layer()(
  list(z_mean, z_log_var)
)

encoder <- keras_model(
  encoder_inputs,
  list(z_mean, z_log_var, z),
  name = "encoder"
)

# -------------------------
# Decoder
# -------------------------
latent_inputs <- layer_input(shape = latent_dim)

decoder_outputs <- latent_inputs |>
  layer_dense(intermediate_dim, activation = "relu") |>
  layer_dense(input_dim, activation = "linear")

decoder <- keras_model(
  latent_inputs,
  decoder_outputs,
  name = "decoder"
)

# -------------------------
# VAE model (modern style)
# -------------------------

vae_model <- new_model_class(
  classname = "VAE",
  
  initialize = function(encoder, decoder, input_dim) {
    super$initialize()
    self$encoder <- encoder
    self$decoder <- decoder
    self$input_dim <- input_dim
  },
  
  call = function(x, mask = NULL) {
    enc <- self$encoder(x)
    z <- enc[[3]]
    self$decoder(z)
  },
  
  train_step = function(data) {
    x <- tf$convert_to_tensor(data)
    
    with(tf$GradientTape() %as% tape, {
      
      enc <- self$encoder(x)
      z_mean <- enc[[1]]
      z_log_var <- enc[[2]]
      z <- enc[[3]]
      
      reconstruction <- self$decoder(z)
      
      recon_loss <- tf$reduce_mean(
        tf$keras$losses$binary_crossentropy(x, reconstruction),
        axis = as.integer(-1)
      )
      
      kl_loss <- -0.5 * tf$reduce_sum(
        1 + z_log_var -
          tf$square(z_mean) -
          tf$exp(z_log_var),
        axis = as.integer(-1)
      )
      step <- tf$cast(self$optimizer$iterations, tf$float32)
      kl_weight <- tf$sigmoid((step - 500) / 200)
      #total_loss <- tf$reduce_mean(recon_loss + kl_loss)
      total_loss <- recon_loss + kl_weight * kl_loss
    })
    
    grads <- tape$gradient(total_loss, self$trainable_variables)
    self$optimizer$apply_gradients(
      purrr::transpose(list(grads, self$trainable_variables))
    )
    
    return(list(loss = total_loss))
  },
  
  test_step = function(data) {
    x <- data
    
    enc <- self$encoder(x)
    z_mean <- enc[[1]]
    z_log_var <- enc[[2]]
    z <- enc[[3]]
    
    reconstruction <- self$decoder(z)
    
    recon_loss <- tf$reduce_mean(
      tf$keras$losses$binary_crossentropy(x, reconstruction),
      axis = as.integer(-1)
    )
    
    kl_loss <- -0.5 * tf$reduce_sum(
      1 + z_log_var -
        tf$square(z_mean) -
        tf$exp(z_log_var),
      axis = as.integer(-1)
    )
    
    kl_loss <- kl_loss / input_dim
    total_loss <- tf$reduce_mean(recon_loss + kl_loss)
    
    list(loss = total_loss)
  }
)
vae <- vae_model(encoder, decoder, input_dim)

vae |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001)
)

summary(vae)
plot(encoder)
plot(decoder)

#### Run model
epochs <- 50
batch_size <- 32

history <- vae %>% fit(
  x = geno_scaled,
  epochs = epochs,
  batch_size = batch_size,
  validation_split = 0.2,
  shuffle = TRUE
)

# Plot training progression natively
plot(history)

# Extract Latent Vectors (means) from the Encoder
encoded_preds <- encoder |> predict(geno_scaled)
vae_latent_coordinates <- as.data.frame(encoded_preds[[1]])
colnames(vae_latent_coordinates) <- c("VAE_1", "VAE_2")

# Bind metadata for plotting
plot_data <- cbind(vae_latent_coordinates, orig_pheno)

# Plot VAE Space
ggplot(plot_data, aes(x = VAE_1, y = VAE_2, color = population)) +
  geom_point(alpha = 0.7, size = 2) +
  theme_minimal() +
  labs(title = "VAE Latent Space Embedding of Populations",
       x = "Latent Dimension 1", y = "Latent Dimension 2")

# Compare with traditional PCA
pca_res <- prcomp(geno_scaled, rank. = 2)
pca_data <- as.data.frame(pca_res$x)
pca_data <- cbind(pca_data, orig_pheno)

ggplot(pca_data, aes(x = PC1, y = PC2, color = population)) +
  geom_point(alpha = 0.7, size = 2) +
  theme_minimal() +
  labs(title = "PCA Embedding of Populations",
       x = "PC 1", y = "PC 2")

