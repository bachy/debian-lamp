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
echo "Git barre repo will be installed in chosen user home directory"
echo "git prod repos will be installed in public_html directory of provided domain, the domain have to exists as shortcut in chosen user/www before running this script. Please run first vhost.sh script and say yes to the question create a shortcut !"

while [ "$vh" != "yes" ] && [ "$vh" != "no" ]
do
  echo -n "Should we create a barre repo? [yes|no] "
  read vh
  # vh=${vh:-y}
done
if [ "$vh" = "yes" ]; then


  # get the current position
  _cwd="$(pwd)"
  # check for assets forlder
  _assets="$_cwd/assets"
  if [ ! -d "$_assets" ]; then
    _assets="$_cwd/../assets"
    if [ ! -d "$_assets" ]; then
      echo "!! can't find assets directory !!"
      exit
    fi
  fi

  # if $user var does not exists (vhost.sh ran directly) ask for it
  if [ -z ${user+x} ]; then
    while [ "$user" = "" ]
    do
      read -p "enter an existing user name ? " user
      if [ "$user" != "" ]; then
        # check if user already exists
        if id "$user" >/dev/null 2>&1; then
          read -p "is user name $user correcte [y|n] " validated
          if [ "$validated" = "y" ]; then
            break
          else
            user=""
          fi
        else
          echo -e "user $user doesn't exists, you must provide an existing user"
          user=""
        fi
      fi
    done
  fi


  while [ "$_domain" = "" ]
  do
  read -p "enter a domain name ? " _domain
  if [ "$_domain" != "" ]; then
    read -p "is domain $_domain correcte [y|n] " validated
    if [ "$validated" = "y" ]; then
      break
    else
      _domain=""
    fi
  fi
  done

  # ask for simple php conf or drupal conf
  while [ "$_drupal" != "yes" ] && [ "$_drupal" != "no" ]
  do
    echo -n "Is your site is a drupal one? [yes|no] "
    read _drupal
  done

  # TODO check for /home/"$user"/www/"$_domain"
  if [ ! -d /home/"$user"/www/"$_domain" ]; then
    echo "/home/$user/www/$_domain does not exists !"
    exit
  fi

  # setup bare repositorie to push to
  mkdir /home/"$user"/git-repositories
  mkdir /home/"$user"/git-repositories/"$_domain".git
  cd /home/"$user"/git-repositories/"$_domain".git
  git init --bare

  echo "adding deploy script"
  if [ "$_drupal" = "yes" ]; then
    cp "$_assets"/deploy-drupal.sh /home/"$user"/www/"$_domain"/deploy.sh
  else
    cp "$_assets"/deploy-simple.sh /home/"$user"/www/"$_domain"/deploy.sh
  fi

  echo "creating hooks that will update the site repo"
  # cp "$_assets"/git-pre-receive /home/"$user"/git-repositories/"$_domain".git/hooks/pre-receive
  cp "$_assets"/git-post-receive /home/"$user"/git-repositories/"$_domain".git/hooks/post-receive

  # sed -i -r "s/PRODDIR=\"www\"/PRODDIR=/home/$user/www/$_domain/g" /home/"$user"/git-repositories/"$_domain".git/hooks/pre-receive
  sed -i -r "s#PRODDIR=\"www\"#PRODDIR=\"/home/$user/www/$_domain\"#g" /home/"$user"/git-repositories/"$_domain".git/hooks/post-receive

  chown -R "$user":"$user" /home/"$user"/git-repositories

  cd /home/"$user"/git-repositories/"$_domain".git/hooks/
  chmod +x post-receive # pre-receive

  # setup git repo on site folder
  cd /home/"$user"/www/"$_domain"/public_html
  git init
  # link to the bare repo
  git remote add origin /home/"$user"/git-repositories/"$_domain".git

  chown -R "$user":"$user" /home/"$user"/www/"$_domain"/public_html

  cd "$_cwd"
  # done
  echo "git repos for $_domain install succeed"
  echo "your site stay now to /home/$user/www/$_domain"
  echo "you can push updates on prod branch through $user@IP.IP.IP.IP:git-repositories/$_domain.git"
  echo "* * *"
else
  echo "Git barre repo creation aborted"
fi
