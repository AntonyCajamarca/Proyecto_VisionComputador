# =====================================================================
# UNIVERSIDAD POLITÉCNICA SALESIANA - Visión por Computador
# Integrantes: Emily Ortega, Antony Cajamarca
# Tema: Sacar de un .zip las imágenes con problemas de contraste
#
# Miramos el histograma con la media (brillo) y la desviación (contraste):
#   - Histograma a la IZQUIERDA  -> SUBEXPUESTA (oscura)
#   - Histograma a la DERECHA    -> SOBREEXPUESTA (clara)
#   - Histograma ESTRECHO al centro -> BAJO CONTRASTE (medio)
#   - Histograma repartido (rectángulo) -> buena, NO se guarda
#
# USO: Ctrl + Shift + Enter. Se abre una ventana para elegir el .zip
# =====================================================================

if (!require(jpeg)) install.packages("jpeg")
if (!require(png))  install.packages("png")
library(jpeg)
library(png)

# ---- Límites (súbelos o bájalos para sacar más o menos imágenes) ----
LIMITE_OSCURA <- 70   # media menor a esto  -> subexpuesta
LIMITE_CLARA  <- 150   # media mayor a esto  -> sobreexpuesta
LIMITE_DESV   <- 50    # desviación menor a esto -> bajo contraste

# ---- Media y desviación (función de la práctica) ----
miStat <- function(P) {
  media <- sum(P) / length(P)
  desviacion <- sqrt(sum((P - media)^2) / length(P))
  c(media, desviacion)
}

# ---- Leer imagen en gris 0..255 ----
leer_gris <- function(ruta) {
  if (grepl("png$", tolower(ruta))) I <- readPNG(ruta) else I <- readJPEG(ruta)
  if (length(dim(I)) == 3) I <- (I[, , 1] + I[, , 2] + I[, , 3]) / 3
  I * 255
}

# ---- Elegir el .zip y descomprimir ----
unlink("imagenes", recursive = TRUE)
unzip(file.choose(), exdir = "imagenes")
rutas <- list.files("imagenes", pattern = "\\.(jpg|jpeg|png)$", recursive = TRUE,
                    full.names = TRUE, ignore.case = TRUE)
rutas <- rutas[!grepl("__MACOSX", rutas)]
cat("Imágenes en el zip:", length(rutas), "\n")

# ---- Crear carpetas de salida ----
unlink("seleccionadas", recursive = TRUE)
dir.create("seleccionadas/Subexpuesta",    recursive = TRUE)
dir.create("seleccionadas/Sobreexpuesta",  recursive = TRUE)
dir.create("seleccionadas/Bajo contraste", recursive = TRUE)

# ---- Revisar cada imagen y copiar las que tienen problema ----
tabla <- data.frame()
for (ruta in rutas) {
  s <- miStat(leer_gris(ruta))
  media <- s[1]
  desv  <- s[2]
  
  if (media < LIMITE_OSCURA) {
    grupo <- "Subexpuesta"
  } else if (media > LIMITE_CLARA) {
    grupo <- "Sobreexpuesta"
  } else if (desv < LIMITE_DESV) {
    grupo <- "Bajo contraste"
  } else {
    grupo <- "Buena (descartada)"
  }
  
  if (grupo != "Buena (descartada)") {
    file.copy(ruta, file.path("seleccionadas", grupo, basename(ruta)))
  }
  
  tabla <- rbind(tabla, data.frame(archivo = basename(ruta), grupo = grupo,
                                   media = round(media, 1), desviacion = round(desv, 1)))
}

# ---- Resultado ----
print(table(tabla$grupo))
print(tabla[order(tabla$grupo), ], row.names = FALSE)
write.csv(tabla, "seleccionadas/clasificacion.csv", row.names = FALSE)
cat("\nImágenes guardadas en:", normalizePath("seleccionadas"), "\n")