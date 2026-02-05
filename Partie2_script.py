import os
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



