$sites = Import-CSV "/eis/hosts.csv"

foreach($site in $sites){
    $DCSF = $site.DCSF
    $URL = $site.URL
    $ExtURL = $site.ExtURL
    $Template = "/eis/template"
    $Target =  "/sites/$DCSF"
    $SitesAvailable = "/sites/sites-available/"
    $DBCreate = "`"CREATE DATABASE wp$DCSF;`""
    Invoke-Expression "mysql -e $DBCreate"

    copy-item $Template $Target -Recurse -Force
    (Get-Content  $Target/vhost.conf).Replace("domain.com",$URL) | Set-Content $Target/vhost.conf
    (Get-Content  $Target/vhost.conf).Replace("domain.kent.sch.uk",$ExtURL) | Set-Content $Target/vhost.conf
    (Get-Content  $Target/vhost.conf).Replace($Template,$Target) | Set-Content $Target/vhost.conf

    copy-item $Target/vhost.conf /etc/apache2/sites-available/$DCSF.conf

    copy-item $Target/wp-config-eis.php $Target/wp-config.php
    Remove-Item $Target/wp-config-eis.php
    $wpconfig = Get-Content  $Target/wp-config.php
    $wpconfig = $wpconfig.Replace("eisdbname","wp$DCSF")
    $wpconfig = $wpconfig.Replace("eisauthkey",$(New-Guid))
    $wpconfig = $wpconfig.Replace("eislogkey",$(New-Guid))
    $wpconfig = $wpconfig.Replace("eisnoncekey",$(New-Guid))
    $wpconfig = $wpconfig.Replace("eisauthsalt",$(New-Guid))
    $wpconfig = $wpconfig.Replace("eissauthsalt",$(New-Guid))
    $wpconfig = $wpconfig.Replace("eislogsalt",$(New-Guid))
    $wpconfig = $wpconfig.Replace("eisnoncesalt",$(New-Guid))
    $wpconfig | Set-Content $Target/wp-config.php

    Invoke-Expression "chown -R www-data $Target"
    Invoke-Expression "chmod -R 755 $Target"
    Invoke-Expression "cp $SitesAvailable$DCSF.conf /etc/apache2/sites-available/$DCSF.conf"
    Invoke-Expression "a2ensite $DCSF.conf"

}

Invoke-Expression "service apache2 reload"
