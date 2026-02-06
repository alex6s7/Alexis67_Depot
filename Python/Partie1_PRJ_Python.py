import os
import requests

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

#Création du dossier image (s'il n'existe pas) pour sauvegarder les images 

dossier="ImagesPython"
os.makedirs(dossier, exist_ok=True)

# Demander à l'utilisateur le nombre d'images souhaité

nombre_images=input("Veuillez choisir un nombre d'images à récupérer : ")

#Télécharger le nombre d'images aléatoires souhaités

for i in range(1,int(nombre_images) + 1):

#Créer un URL

    url="https://picsum.photos/800/600?random="+ str(i)
    reponse = requests.get(url)
    
    if reponse.status_code==200 :
    #Créer le chemin d'accès à chaque image 
       nom_fichier=f"Image"+str(i)+".jpg"
       path_image=os.path.join(dossier,nom_fichier)
    #Ouvrir le fichier en binaire
       fichier=open(path_image,'wb')
    #Ecrire le contenu de retour de la requête
       fichier.write(reponse.content)
    #Fermer le fichier
       fichier.close()
    #Témoin de sauvegarde dans la console 
       print ("Image", str(i), "sauvegardée avec succès !")
    else :
        print("ERREUR pour l'image", str (i))



from moviepy.editor import *

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

durée_image = 3

#Définition du dossier contenant les images 
dossier_images = "ImagesPython"

#Récupération liste images dans l'ordre
images = sorted(os.listdir(dossier_images))

#Création d'une liste vide 
list = []

#Création d'une boucle pour chaque image une par une 
for image in images:
    if image.lower().endswith(".jpg"):
        path_clip = os.path.join(dossier_images, image)

        clip = ImageClip(path_clip).set_duration(durée_image)
        list.append(clip)

#Ajouter du texte dans le diaporame (installer imagemaking) :

        #txt_clip = TextClip("Diaporama de bogoss", fontsize = 75, color = 'white') 
        #txt_clip = txt_clip.set_pos('center').set_duration(10) 
        #video = CompositeVideoClip([clip, txt_clip])

video = concatenate_videoclips(list, method="compose")

#Ajout de musique : 

musique = AudioFileClip ("Carioca.mp4")
video = video.set_audio(musique)

video.write_videofile("diaporama de bogoss.mp4", fps=24)
print("🎉 Diaporama créé avec succès !")
