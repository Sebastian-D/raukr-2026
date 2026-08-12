# Vanilla AE

library(keras3)
library(tidyverse)
library(ggplot2)
library(plotly)

load("slides/ai_models/genodata_5k.Rd")

orig_pheno <- read_csv("slides/ai_models/autosomal_5k_phenos.csv") |> 
  select(-1) |> 
  mutate(population = population |> replace_values('MEX' ~ 'MXL')) |>
  rename(pop = population)
pop_info <- read_delim("slides/ai_models/pop_legend.csv", delim = ';')
orig_pheno <- orig_pheno |>
  left_join(
    pop_info |> select(pop, name),
    by = "pop"
  ) |>
  rename(Population = name)

# -------------------------
# Data
# -------------------------

x_train <- as.matrix(orig_geno) / 2

# Traditional PCA
pca_res <- prcomp(x_train, rank. = 2)
pca_data <- as.data.frame(pca_res$x)
pca_data <- cbind(pca_data, orig_pheno)

ggplot(pca_data, aes(x = PC1, y = PC2, color = Population)) +
  geom_point(alpha = 0.7, size = 2) +
  theme_minimal() +
  labs(title = "PCA Embedding of Populations",
       x = "PC1", y = "PC2")


# Autoencoder 
input_dim <- ncol(x_train)
latent_dim <- 2

# 1. Encoder
encoder <- keras_model_sequential(name = "encoder") |>
  layer_dense(256, activation = "relu", input_shape = input_dim) |>
  layer_dense(128, activation = "relu") |>
  layer_dense(latent_dim)

# 2. Decoder
decoder <- keras_model_sequential(name = "decoder") |>
  layer_dense(128, activation = "relu", input_shape = latent_dim) |>
  layer_dense(256, activation = "relu") |>
  layer_dense(input_dim)

# 3. Autoencoder (combines encoder & decoder directly)
autoencoder <- keras_model_sequential(layers=list(encoder, decoder), name = "autoencoder")

# Plot all models cleanly
plot(encoder, show_layer_names = TRUE, show_shapes = TRUE, expand_nested = TRUE)
plot(decoder, show_layer_names = TRUE, show_shapes = TRUE, expand_nested = TRUE)
plot(autoencoder, show_layer_names = TRUE, show_shapes = TRUE, expand_nested = TRUE)

# Compile
autoencoder |> compile(
  optimizer = optimizer_adam(),
  loss = loss_mean_squared_error
)


# -------------------------
# Train
# -------------------------

history <- autoencoder |> fit(
  x = x_train,
  y = x_train,
  epochs = 50,
  batch_size = 32,
  validation_split = 0.2,
  shuffle = TRUE
)

plot(history)

latent <- predict(encoder, x_train)

scores <- as.data.frame(latent)
colnames(scores) <- c("Z1", "Z2")

scores$Population <- orig_pheno$Population

ggplot(scores, aes(Z1, Z2, colour = Population)) +
  geom_point(size = 2) +
  theme_classic() +
  ggsci::scale_color_d3("category20")

x_recon <- predict(autoencoder, x_train)
mean((x_train - x_recon)^2)