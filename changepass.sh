#!/bin/bash

linux_user=acunetix
product_name=acunetix


if [ "$EUID" -ne 0 ]
    then echo "Please run as root."
    exit -1
fi

base_folder="/home/$linux_user/.$product_name"

get_settings_from_ini()
{
    db_user=$(awk -F "=" '/databases.connections.master.connection.user/ {print $2}' $base_folder/wvs.ini)
    if [ -z "$db_user" ]; then
        echo "Acunetix installation found at $base_folder, but has invalid wvs.ini file. Aborting installation."
        echo
        exit -1
    fi

    db_host=$(awk -F "=" '/databases.connections.master.connection.host/ {print $2}' $base_folder/wvs.ini)
    if [ -z "$db_host" ]; then
        echo "Acunetix installation found at $base_folder, but has invalid wvs.ini file. Aborting installation."
        echo
        exit -1
    fi

    db_port=$(awk -F "=" '/databases.connections.master.connection.port/ {print $2}' $base_folder/wvs.ini)
    if [ -z "$db_port" ]; then
        echo "Acunetix installation found at $base_folder, but has invalid wvs.ini file. Aborting installation."
        echo
        exit -1
    fi

    db_name=$(awk -F "=" '/databases.connections.master.connection.db/ {print $2}' $base_folder/wvs.ini)
    if [ -z "$db_name" ]; then
        echo "Acunetix installation found at $base_folder, but has invalid wvs.ini file. Aborting installation."
        echo
        exit -1
    fi

    db_password=$(awk -F "=" '/databases.connections.master.connection.password/ {print $2}' $base_folder/wvs.ini)
    if [ -z "$db_password" ]; then
        echo "Acunetix installation found at $base_folder, but has invalid wvs.ini file. Aborting installation."
        echo
        exit -1
    fi

    gr="(?<=wvs\.app_dir\=~\/\.$product_name\/v_)[0-9]+(?=\/scanner)"
    version_numeric=$(cat $base_folder/wvs.ini | grep -o -P $gr)
    version="v_$version_numeric"
}

get_settings_from_ini
db_pgdir="$base_folder/$version/database"


run_db_sql(){

    sudo -u $linux_user PGPASSWORD=$db_password $db_pgdir/bin/psql -q -d $db_name -t -c "$1" -b -h $db_host -p $db_port -U $db_user -v ON_ERROR_STOP=1
    if [ "$?" -ne 0 ]; then
        echo "Error running SQL command. Exiting."
        exit -1
    fi
}

get_password_score()
{
    score=0
    if [[ $1 =~ [A-Z] ]]; then
            #echo "CAPS found"
            score=$(( $score+1 ))
    fi

    if [[ $1 =~ [a-z] ]]; then
            #echo "normal found"
            score=$(( $score+1 ))
    fi

    if [[ $1 =~ [0-9] ]]; then
            #echo "number found"
            score=$(( $score+1 ))
    fi

    if [[ $1 =~ [!-/:-@\[-\`{-~] ]]; then
            #echo "special found"
            score=$(( $score+1 ))
    fi

    return $score
}


default_command()
{
  #get the previous master user
  qr=$(run_db_sql "SELECT email FROM users WHERE user_id='986ad8c0a5b3df4d7028d5f3c06e936c'")
  master_user=$(echo "$qr" | awk '{$1=$1};1')

  #echo "Master user found: $master_user"


  regex="^([A-Za-z]+[A-Za-z0-9]*((\.|\-|\_)?[A-Za-z]+[A-Za-z0-9]*){1,})@(([A-Za-z]+[A-Za-z0-9]*)+((\.|\-|\_)?([A-Za-z]+[A-Za-z0-9]*)+){1,})+\.([A-Za-z]{2,})+"
  while true; do
      new_master_user=vhae04@gmail.com

      if [ -z $new_master_user ]; then
          break
      fi

      echo $new_master_user | egrep --quiet $regex

      if [ "$?" -eq 0 ] ; then
          master_user=$new_master_user
          break
      else
          echo "Bad email format. Please try again."
      fi
  done

  master_user=${master_user,,}

  #echo "Using master user $master_user"

  while true; do
      master_password=Vhae@04

      master_password2=Vhae@04
      echo
      [ "$master_password" = "$master_password2" ] && break
      echo "Passwords don't match. Please try again."
  done

  run_db_sql "UPDATE users SET email='$master_user', password=encode(digest('$master_password', 'sha256'), 'hex'), pwd_expires = null, otp=null, otp_required=false WHERE user_id='986ad8c0a5b3df4d7028d5f3c06e936c'"
  run_db_sql "update users set pwd_expires = NOW() + interval '1 day' * pwd_max_age where pwd_max_age is not null and pwd_max_age != 0 and user_id='986ad8c0a5b3df4d7028d5f3c06e936c'"
  run_db_sql "DELETE FROM ui_sessions"
}

command="reset_password"

while getopts u:c: flag
do
    case "${flag}" in
        c) command=${OPTARG};;
        u) email=${OPTARG};;
    esac
done

if [ "$command" == "reset_password" ]; then
  default_command
fi

if [ "$command" == "reset_api_key" ]; then

  qr=$(run_db_sql "SELECT replace(user_id::text, '-', '') FROM users WHERE email='$email'")
  user_id=$(echo "$qr" | awk '{$1=$1};1')

  if [ -z "$user_id" ]; then
    echo "user $email not found"
    exit 1;
  fi

  db_api_key=$(tr -dc a-f0-9 </dev/urandom | head -c 32 ; echo '')

  run_db_sql "UPDATE users SET api_key='$db_api_key' WHERE user_id='$user_id'"

  #echo "api_key=1$user_id$db_api_key"

fi
