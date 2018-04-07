#!/bin/sh
# bachir soussi chiadmi

# get the current position
_cwd="$(pwd)"

echo -e '\033[35m
   _______ __
  / ____(_) /_
 / / __/ / __/
/ /_/ / / /_
\____/_/\__/             
\033[0m'
echo -e "\033[35;1mCreate new git barre repos and deploy script\033[0m"


while [ "$_bare_name" = "" ]
do
  read -p "enter the bare repos folder name ? " _bare_name
  if [ "$_bare_name" != "" ]; then
    read -p "is bare folder name $_bare_name correcte [y|n] " validated
    if [ "$validated" = "y" ]; then
      break
    else
      _bare_name=""
    fi
  fi
done

while [ "$_prod_folder_path" = "" ]
do
  read -p "enter the prod folder path (must be a public_html parent's) ? " _prod_folder_path
  if [ "$_prod_folder_path" != "" ]; then
    # TODO check if path exists
    read -p "is prod folder path $_prod_folder_path correcte [y|n] " validated
    if [ "$validated" = "y" ]; then
      break
    else
      _prod_folder_path=""
    fi
  fi
done

# ask for simple php conf or drupal conf
while [ "$_drupal" != "yes" ] && [ "$_drupal" != "no" ]
do
  echo -n "Is your site is a drupal one? [yes|no] "
  read _drupal
done

# setup bare repositorie to push to
mkdir ~/git-repositories
mkdir ~/git-repositories/"$_bare_name".git
cd ~/git-repositories/"$_bare_name".git
git init --bare

# add deploy script
if [ "$_drupal" = "yes" ]; then
  cp "$_cwd"/assets/deploy-drupal.sh "$_prod_folder_path"/deploy.sh
else
  cp "$_cwd"/assets/deploy-simple.sh "$_prod_folder_path"/deploy.sh
fi

# setup git repo on site folder
cd "$_prod_folder_path"
git init
# link to the bare repo
git remote add origin /home/"$USER"/git-repositories/"$_bare_name".git

# create hooks that will update the site repo
cd ~
cp "$_cwd"/assets/git-pre-receive /home/"$USER"/git-repositories/"$_bare_name".git/hooks/pre-receive
cp "$_cwd"/assets/git-post-receive /home/"$USER"/git-repositories/"$_bare_name".git/hooks/post-receive

sed -ir "s/PRODDIR=\"www\"/PRODDIR=$_prod_folder_path/g" /home/"$USER"/git-repositories/"$_bare_name".git/hooks/pre-receive
sed -ir "s/PRODDIR=\"www\"/PRODDIR=$_prod_folder_path/g" /home/"$USER"/git-repositories/"$_bare_name".git/hooks/post-receive

cd /home/"$USER"/git-repositories/"$_bare_name".git/hooks/
chmod +x post-receive pre-receive

# done
echo "git repos for $_bare_name install succeed"
echo "your site stay now to $_prod_folder_path"
echo "you can push updates on prod branch through $USER@IP.IP.IP.IP:git-repositories/$_bare_name.git"
echo "* * *"
