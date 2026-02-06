#BARBERET ALEXIS 
#04/02/2026
#Projet R_studio


library(tidyverse)
library(ggplot2)

# Chargement des données
read_csv2("global-shark-attack.csv") -> SHARK
SHARK
glimpse(SHARK)
View(SHARK)

# Nombre total d'attaques 
nrow(SHARK)
# Nombre de variables
ncol(SHARK)
# Types de variables
sapply(SHARK, class)
# Valeurs manquantes
colSums(is.na(SHARK))

SHARK %>%
  count(Year, sort = TRUE) #nombre d'attaques par année

SHARK %>%
  count(Country, sort = TRUE) #nombre d'attaque par pays

#Croisement de plusieurs variables

SHARK %>%
  count(Country, Fatal) %>% #compte par année et par gravité
  arrange(desc(n))

SHARK %>%
  count(Year, Fatal)


#Nouvelle donnée pour la jointure : classer les pays selon leur niveaux d'exposition

SHARK %>%
  filter(!is.na(Country)) %>%  #on enlève les lignes sans pays
  count(Country) %>%
  mutate(niveau_exposition = case_when( #mutate -> créer une nouvelle variable
      n >= 200 ~ "Très élevé",
      n >= 100 ~ "Élevé",
      n >= 50  ~ "Modéré",
      TRUE     ~ "Faible")) %>%  #différents conditions permettant d'obtenir un niveau
  
  select(Country, niveau_exposition) ->pays_exposition 

#Jointure 

SHARK %>% 
  left_join(pays_exposition, by = "Country") -> shark_joined  #fusionne avec la colonne "Country"
#left_join permet de garder toutes les lignes de la data

view(shark_joined) 

#Création d'une variable temporelle pour le graphique 

shark_joined %>%
  mutate(Periode = case_when(
      Year < 2000 ~ "Avant 2000",
      Year >= 2000 ~ "Après 2000")) -> shark_joined 

#Calcul du pourcentage d'attaques mortelles/ non mortelles par pays (indicateurs possible pour le graphique)

shark_joined %>%
  filter(Fatal %in% c("Y", "N"),!is.na(Country),!is.na(Periode)) %>%
      count(Country, Fatal,Periode) %>% #compte par pays, par gravité et par rapport à des périodes
      group_by(Country,Periode) %>% #regroupe par pays et périodes
  
      mutate(total = sum(n),pct = n / total * 100) %>% #Total d'attaques par pays (toutes gravités)
      ungroup() -> shark_plot

shark_plot

# Top des pays avec le plus d'attaques --> filtre pour le ggplot

shark_plot %>%
  group_by(Country) %>%
  summarise(total = sum(n)) %>% #garder une seule ligne par pays (total compris)
  arrange(desc(total)) %>%
  slice_head(n = 5) %>% #garder 5 premières lignes 
  pull(Country) -> top5_pays

shark_plot %>% #filtrer la fonction pour ne garder que les données du top 5
  filter(Country %in% top5_pays) ->shark_plot_top5 

shark_plot_top5

# ggplot2 : Graphique en barre 

shark_plot_top5 %>%
  mutate(Fatal = recode(Fatal, "Y" = "Mortel", 
                               "N" = "Non mortel")) %>%
  
  ggplot(aes(x = reorder(Country, -total),y = n,fill = Fatal)) +  #mapping
  #Axe x : Pays par ordre croissant 
  #Axe Y : nombre d'attaques
  #Fill : couleur de remplissage selon catégorie Fatal
  geom_col(position = "dodge", width = 0.7) +
  #Barres empilées 
  #geom_col = barres avec hauteurs = valeurs Y
  
  # Valeurs sur les barres
  geom_text(aes(label = n),position = position_dodge(width = 0.7),vjust = -0.3, size = 3) +
  
  # Facets par période : 
  
  facet_wrap(~ Periode) + #facet wrap : il trouve tt seul comment faire 
  
  coord_flip() + #Inverse X et Y

#Scales : pas besoin de beaucou
  
  scale_fill_manual(values = c("Non mortel" = "#62BD6A", "Mortel" = "#C23117")) +
  
#Options
    ggtitle ("Top 5 des pays : comparaison attaques mortelles vs non mortelles") + 
    xlab("Pays") +
    ylab("Nombre d'attaques") +
    labs(subtitle = "Évolution Avant 2000 vs Après 2000",fill = "Issue de l'attaque") + 
  
  theme_bw() +  #Theme Black and white 
  theme(
    plot.title = element_text(face = "bold", size = 13),  #Titre en gras 
    plot.subtitle = element_text(size = 10, color = "#626662"), #Sous titre en gris clair
    axis.title = element_text(face = "bold"),
    axis.text.y = element_text(face = "bold"), #Nom des pays en gras 
    legend.position = "bottom",               #legende placée en bas 
    strip.background = element_rect(fill = "#677CF0"),  
    strip.text = element_text(color = "white", face = "bold"))






