# =====================================================================
# Descripción del conjunto de imágenes (versión rápida para MILES de imágenes)
#   - Clases y cardinalidad  -> se cuentan TODAS las imágenes (rápido)
#   - Formato y peso         -> TODAS las imágenes (no hace falta abrirlas)
#   - Tamaño y profundidad   -> una MUESTRA al azar (abrir cada imagen es lento)
#
# Cada CLASE es una subcarpeta:  CARPETA/clase1/..., CARPETA/clase2/...
# USO: cambia CARPETA y pulsa Ctrl + Shift + Enter
# =====================================================================

if (!require(jpeg)) install.packages("jpeg")
if (!require(png))  install.packages("png")
library(jpeg)
library(png)

CARPETA <- "C:/Users/mcaja/OneDrive/Escritorio/transporte"  # carpeta con una subcarpeta por clase
MUESTRA <- 10000          # cuántas imágenes se abren para medir tamaño y bits

# ---- 1. Listar todas las imágenes (no las abre, por eso es rápido) ----
rutas <- list.files(CARPETA, pattern = "\\.(jpg|jpeg|png)$", recursive = TRUE,
                    full.names = TRUE, ignore.case = TRUE)
rutas <- rutas[!grepl("__MACOSX", rutas)]

formato <- toupper(tools::file_ext(rutas))
formato[formato == "JPEG"] <- "JPG"
clase   <- basename(dirname(rutas))
peso_KB <- file.size(rutas) / 1024

cat("Total de imágenes:", length(rutas), "\n")

# ---- 2. Formato ----
cat("\n===== FORMATO =====\n")
print(table(formato))

# ---- 3. Peso ----
cat("\n===== PESO DE LOS ARCHIVOS =====\n")
cat("Peso promedio:", round(mean(peso_KB), 1), "KB\n")
cat("Peso mínimo  :", round(min(peso_KB), 1), "KB\n")
cat("Peso máximo  :", round(max(peso_KB), 1), "KB\n")
cat("Peso total   :", round(sum(peso_KB) / 1024, 1), "MB\n")

# ---- 4. Clases y cardinalidad ----
cardinalidad <- sort(table(clase), decreasing = TRUE)
cat("\n===== CLASES =====\n")
cat("Número de clases:", length(cardinalidad), "\n")
cat("Imágenes por clase -> promedio:", round(mean(cardinalidad), 1),
    " mínimo:", min(cardinalidad), " máximo:", max(cardinalidad), "\n")

cat("\nClases con MÁS imágenes:\n");   print(head(cardinalidad, 10))
cat("\nClases con MENOS imágenes:\n"); print(tail(cardinalidad, 10))

barplot(cardinalidad, names.arg = NA, col = "steelblue", border = NA,
        main = "Cardinalidad de cada clase (ordenada)", ylab = "Imágenes", xlab = "Clases")

# ---- 5. Tamaño y profundidad de bit (con una muestra) ----
set.seed(1)
elegidas <- sample(rutas, min(MUESTRA, length(rutas)))
ancho <- c(); alto <- c(); bits <- c()

for (i in seq_along(elegidas)) {
  ruta <- elegidas[i]
  if (grepl("png$", tolower(ruta))) {
    I <- readPNG(ruta, info = TRUE)
    bits_canal <- attr(I, "info")$bit.depth
  } else {
    I <- readJPEG(ruta)
    bits_canal <- 8
  }
  canales <- ifelse(length(dim(I)) == 3, dim(I)[3], 1)
  alto[i]  <- dim(I)[1]
  ancho[i] <- dim(I)[2]
  bits[i]  <- bits_canal * canales
  if (i %% 50 == 0) cat("  revisadas", i, "de", length(elegidas), "\n")   # para ver que avanza
}

cat("\n===== TAMAÑO PROMEDIO (muestra de", length(elegidas), "imágenes) =====\n")
cat("Ancho promedio:", round(mean(ancho)), "px\n")
cat("Alto promedio :", round(mean(alto)),  "px\n")
cat("Más pequeña   :", min(ancho), "x", min(alto), "px\n")
cat("Más grande    :", max(ancho), "x", max(alto), "px\n")

cat("\n===== PROFUNDIDAD DE BIT =====\n")
print(table(paste(bits, "bits")))

# ---- 6. Guardar cardinalidad ----
write.csv(as.data.frame(cardinalidad), "cardinalidad_clases.csv", row.names = FALSE)
cat("\nCardinalidad guardada en cardinalidad_clases.csv\n")