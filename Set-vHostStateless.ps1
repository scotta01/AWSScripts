param(
    $DCSF,
    $SiteRoot = "/sites/",
    $URL,
    $ExtURL
)
begin{
    $Template = "/eis/template" 
    $SitesAvailable = "/sites/sites-available/"
    $URLTemplate = "domain.com"
    $ExtURLTemplate = "domain.kent.sch.uk"
}
process{
    
    $Target =  "$SiteRoot$DCSF"
    $DBCreate = "`"CREATE DATABASE wp$DCSF;`""
    
    Invoke-Expression "mysql -e $DBCreate"

    copy-item $Template $Target -Recurse -Force

    $vhost = Get-Content $Target/vhost.conf
    $vhost = $vhost.Replace($URLTemplate,$URL)
    $vhost = $vhost.Replace($ExtURLTemplate,$ExtURL) | Set-Content $Target/vhost.conf
    $vhost = $vhost.Replace($Template,$Target) | Set-Content $Target/vhost.conf
    $vhost | Set-Content $Target/vhost.conf

    copy-item $Target/vhost.conf $SitesAvailable$DCSF.conf

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

    Invoke-Expression "chown -R www-data:www-data $Target"
    Invoke-Expression "chmod -R 775 $Target"

    copy-item $SitesAvailable$DCSF.conf /etc/apache2/sites-available/$DCSF.conf
    Invoke-Expression "a2ensite $DCSF.conf" 
}
end{
    Invoke-Expression "service apache2 reload"
}