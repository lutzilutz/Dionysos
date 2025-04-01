class_name ReadMe extends Node

var main_scene
var working_renders: String = ""
var final_renders: String = ""
var drop_box: String = ""
var notes: String = ""

func generate_readme_content() -> String:
	
	var s: String = ""
	s = "Bienvenue dans le dossier du projet \"" + main_scene.project_name + "\" de " + main_scene.customer_name + ".
Vous trouverez ci-dessous des indications sur la structure du projet et les emplacements intéressants.
Pour toute question d'ordre technique, merci de bien vouloir écrire à : lutz@drykats.ch

========== Équipe ==========

   ----- Montage -----
	  Monteur : " + main_scene.editor_name + "
	  Téléphone : " + main_scene.editor_phone + "
	  Email : " + main_scene.editor_email + "

========== Informations au client ==========

   ----- En résumé -----
	  Vidéos temporaires : " + working_renders + "
	  Vidéos finales : " + final_renders + "
	  Pour nous transmettre vos logos : " + drop_box + "
 
   ----- Logo et charte -----
	  Vous pouvez déposer à tout moment vos logos et chartes graphiques à l'emplacement :
	  " + drop_box + "
	  Formats idéaux : PNG, PDF, PS, BMP
	  Formats à éviter : JPG/JPEG, GIF

   ----- Rendus -----
	  Nous utilisons une numérotation séquentielle pour les versions : v01, v02, v03, ...
	  Cette numérotation est présente dans les noms de fichier ainsi que dans les vidéos.

	  Vous trouverez les rendus temporaires qui vous sont destinés dans :
	  " + working_renders + "

	  Vous trouverez la version finale du projet dans :
	  " + final_renders + "

	  Le dossier \"" + notes + "\" peut contenir vos notes, retours, indications, ou PV de réunion."
	return s
