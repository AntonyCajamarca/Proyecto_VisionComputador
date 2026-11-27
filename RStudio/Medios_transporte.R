ORIGEN  <- "C:/Users/mcaja/OneDrive/Escritorio/ProyectoVC"
DESTINO <- "C:/Users/mcaja/OneDrive/Escritorio/transporte"

tierra <- c("ambulance","amphibian","beach_wagon","bicycle_built_for_two","bobsled",
            "bullet_train","cab","convertible","dogsled","electric_locomotive","fire_engine",
            "forklift","freight_car","garbage_truck","go_kart","golfcart","half_track",
            "harvester","horse_cart","jeep","jinrikisha","limousine","minibus","minivan",
            "mobile_home","model_t","moped","motor_scooter","mountain_bike","moving_van",
            "oxcart","passenger_car","pickup","police_van","racer","recreational_vehicle",
            "school_bus","snowmobile","snowplow","sports_car","steam_locomotive","streetcar",
            "tank","tow_truck","tractor","trailer_truck","tricycle","trolleybus","unicycle")
agua   <- c("aircraft_carrier","canoe","catamaran","container_ship","fireboat","gondola",
            "lifeboat","liner","paddlewheel","pirate","schooner","speedboat","submarine",
            "trimaran","wreck","yawl")
aire   <- c("airliner","airship","space_shuttle","warplane")

clases <- c(tierra, agua, aire)
dir.create(DESTINO, showWarnings = FALSE)

for (cl in clases) {
  carpeta <- file.path(ORIGEN, cl)
  if (dir.exists(carpeta)) {
    file.copy(carpeta, DESTINO, recursive = TRUE)
    cat("Copiada:", cl, "\n")
  } else {
    cat("No existe:", cl, "\n")
  }
}
cat("Clases copiadas:", length(list.dirs(DESTINO, recursive = FALSE)), "\n")


install.packages(c("usethis", "gitcreds"))

usethis::use_git_config(
  user.name  = "Antony Cajamarca",
  user.email = "antonycg2004@gmail.com"   # el mismo correo de GitHub
)

usethis::create_github_token()   # se abre GitHub: pulsa "Generate token" y copia el token
gitcreds::gitcreds_set()         # pega el token cuando te lo pida

usethis::use_git() 
usethis::use_github() 