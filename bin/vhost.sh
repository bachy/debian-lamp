
echo '\033[35m
        __               __
 _   __/ /_  ____  _____/ /_
| | / / __ \/ __ \/ ___/ __/
| |/ / / / / /_/ (__  ) /_
|___/_/ /_/\____/____/\__/
\033[0m'
echo "\033[35;1mNginx VHOST install \033[0m"
while [ "$vh" != "y" ] && [ "$vh" != "n" ]
do
  echo -n "Should we install a vhost? [y|n] "
  read vh
  # vh=${vh:-y}
done
if [ "$vh" = "y" ]; then

  while [ "$_domain" = "" ]
  do
  read -p "enter a hostname ? " _domain
  if [ "$_domain" != "" ]; then
    read -p "is hostname $_domain correcte [y|n] " validated
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

  # ask for let's encrypt
  while [ "$_letsencrypt" != "yes" ] && [ "$_letsencrypt" != "no" ]
  do
    echo "Let's encrypt"
    echo "Let's encrypt needs a public registered domain name with proper DNS records ( A records or CNAME records for subdomains pointing to your server)."
    echo -n "Should we install let's encrypt certificate with $_domain? [yes|no] "
    read _letsencrypt
  done

  # lets'encrypt
  # https://certbot.eff.org/lets-encrypt/debianstretch-nginx
  if [ "$_letsencrypt" = "yes" ]; then
    apt-get install certbot
    certbot certonly --cert-name "$_domain" --standalone –d "$_domain"
    openssl dhparam –out /etc/nginx/dhparam.pem 2048
    # TODO renewing
    touch /var/spool/crontab/root
    crontab -l > mycron
    echo "0 3 * * * certbot renew --pre-hook 'systemctl stop nginx' --post-hook 'systemctl start nginx' --cert-name $_domain" >> mycron
    crontab mycron
    rm mycron
  fi

  if [ "$_drupal" = "yes" ]; then
    if [ "$_letsencrypt" = "yes" ]; then
      _conffile = "drupal-ssl.nginxconf"
    else
      _conffile = "drupal.nginxconf"
    fi
  else
    if [ "$_letsencrypt" = "yes" ]; then
      _conffile = "simple-phpfpm-ssl.nginxconf"
    else
      _conffile = "simple-phpfpm.nginxconf"
    fi
  fi

  cp "$_cwd"/assets/"$_conffile" /etc/nginx/sites-available/"$_domain".conf
  sed -ir "s/DOMAIN\.LTD/$_domain/g" /etc/nginx/sites-available/"$_domain".conf

  mkdir -p /var/www/"$_domain"/public_html
  mkdir /var/www/"$_domain"/logs
  #set proper right to user will handle the app
  chown -R root:admin  /var/www/"$_domain"/
  chmod -R g+w /var/www/"$_domain"/
  chmod -R g+r /var/www/"$_domain"/

  # create a shortcut to the site
  # TODO ask for $user name if not existing

  echo -n "Should we install a shortcut for a user? [Y|n] "
  read yn
  yn=${yn:-y}
  if [ "$yn" = "y" ]; then
    if [ -z ${user+x} ]; then
      echo -n "Enter an existing user name: "
      read user
      while [ "$user" = "" ]
      do
        read -p "enter a user name ? " user
        if [ "$user" != "" ]; then
          check if user already exists
          if id "$user" >/dev/null 2>&1; then
            read -p "is user name $user correcte [y|n] " validated
            if [ "$validated" = "y" ]; then
              break
            else
              user=""
            fi
          else
            echo "user $user doesn't exists, you must provide an existing user"
            user=""
          fi
        fi
      done
    fi

    echo "shortcut will be installed for '$user'";
    sleep 3

    mkdir /home/"$user"/www/
    chown "$user":admin /home/"$user"/www/
    ln -s /var/www/"$_domain" /home/"$user"/www/"$_domain"

  else
    echo 'no shortcut installed'
  fi
  # activate the vhost
  ln -s /etc/nginx/sites-available/"$_domain".conf /etc/nginx/sites-enabled/"$_domain".conf

  # restart nginx
  systemctl restart nginx
  echo "\033[92;1mvhost $_domain configured\033[Om"
else
  echo "Vhost installation aborted"
fi
