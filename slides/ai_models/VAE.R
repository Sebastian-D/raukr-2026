library(keras3)
library(tensorflow)
library(tidyverse)
library(ggplot2)
library(plotly)

load('slides/ai_models/genodata_5k.Rd')

orig_pheno <- read_csv(
  "slides/ai_models/autosomal_5k_phenos.csv",
  col_names = TRUE
) |>
  select(-1)

# -------------------------
# Data
# -------------------------
geno_scaled <- as.matrix(orig_geno) / 2.0
input_dim <- ncol(geno_scaled)
latent_dim <- 2

# -------------------------
# Encoder
# -------------------------
inputs <- layer_input(shape = input_dim)

h <- inputs |>
  #layer_dense(512, activation = "relu") |>
  layer_dense(256, activation = "relu") |>
  layer_dense(128, activation = 'relu')

# Branch out
z_mean <- layer_dense(h, latent_dim)
z_log_var <- layer_dense(h, latent_dim)

# -------------------------
# Define sampling layer
# -------------------------
SamplingLayer <- new_layer_class(
  classname = "SamplingLayer",
  
  call = function(self, inputs) {
    z_mean <- inputs[[1]]
    z_log_var <- inputs[[2]]
    
    epsilon <- tensorflow::tf$random$normal(
      shape = tensorflow::tf$shape(z_mean)
    )
    
    z_mean + tensorflow::tf$exp(0.5 * z_log_var) * epsilon
  },
  
  compute_output_shape = function(self, input_shape) {
    input_shape[[1]]
  }
)

z <- SamplingLayer()(list(z_mean, z_log_var))

encoder <- keras_model(
  inputs = inputs,
  outputs = list(z_mean, z_log_var, z),
  name = "encoder"
)

# -------------------------
# Decoder
# -------------------------
latent_inputs <- layer_input(shape = latent_dim)

x <- latent_inputs |>
  layer_dense(128, activation = "relu") |>
  layer_dense(256, activation = "relu") |>
  #layer_dense(512, activation = "relu") |>
  layer_dense(input_dim, activation = "linear")

decoder <- keras_model(latent_inputs, x, name = "decoder")

# -------------------------
# VAE model
# -------------------------
outputs <- decoder(z)
vae <- keras_model(inputs, outputs, name = "vae")

# -------------------------
# LOSS (FIXED Keras 3 way)
# -------------------------
#reconstruction_loss <- function(y_true, y_pred) {
#  loss_binary_crossentropy(y_true, y_pred) * input_dim
#}
vae |> compile(
  optimizer = "adam",
  loss = loss_huber
) 

x_train <- geno_scaled
x_train <- as.matrix(x_train)
storage.mode(x_train) <- "double"

vae |> fit(
  x = x_train,
  y = x_train,
  epochs = 50,
  batch_size = 32,
  validation_split = 0.2,
  shuffle = TRUE
)

encoder <- keras_model(inputs, list(z_mean, z_log_var, z))
latent <- predict(encoder, x_train)
z_mean      <- latent[[1]]
z_log_var   <- latent[[2]]
z_sampled   <- latent[[3]]
#pca <- prcomp(z_mean, center = TRUE, scale. = TRUE)
#scores <- as.data.frame(pca$x[, 1:2])
#colnames(scores) <- c("PC1", "PC2")

scores <- as.data.frame(z_mean[,1:2])
scores$Population <- orig_pheno$population

g <- ggplot(scores, aes(V1, V2, colour = Population)) +
  geom_point(size = 2) +
  theme_classic() +
  scale_colour_viridis_d(option = "H")
ggplotly(g)

x_recon <- predict(decoder, z_sampled)
mean((x_train - x_recon)^2)

#####
#African Ancestry
#  YRI: Yoruba in Ibadan, Nigeria
#  LWK: Luhya in Webuye, Kenya
#  MKK: Maasai in Kinyawa, Kenya
#  ASW: African ancestry in Southwest USA
#European Ancestry
#  CEU: Utah residents with Northern and Western European ancestry (CEPH collection)
#  TSI: Toscani in Italia (Tuscans in Italy)
# Asian Ancestry
#  CHB: Han Chinese in Beijing, China
#  CHD: Chinese in metropolitan Denver, Colorado, USA
#  JPT: Japanese in Tokyo, JapanAdmixed & South Asian Ancestry
#  MXL: Mexican ancestry in Los Angeles, California, USA
#  GIH: Gujarati Indians in Houston, Texas, USA
