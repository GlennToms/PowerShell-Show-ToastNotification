function New-ToastNotification {
    <#
        .SYNOPSIS
        Creates custom Windows Toast notifications with titles and text
        
        .DESCRIPTION
        Creates custom Windows Toast notifications with titles and text

        .PARAMETER ApplicationTitle
        Specifies the title of the application that created the Toast notification

        .PARAMETER ToastTitle
        Specifies the title of the Toast notification 

        .PARAMETER ToastBody
        Specifies the text of the Toast notification 
        
        .EXAMPLE
        PS> Show-ToastNotification -ApplicationTitle "PomodoroTimer" -ToastBody "Deep work ended"
        
        .EXAMPLE
        PS> "This is body text" | Show-ToastNotification

        .LINK
        https://github.com/GlennToms/Powershell-Pomodoro-Timer
        
        .LINK
        https://den.dev/blog/powershell-windows-notification/

        .LINK
        https://github.com/GlennToms/Powershell-Pomodoro-Timer

        .NOTES
        Updated for use with Pomodoro Timer
    #>
    [cmdletbinding()]
    Param (
        [string]
        $ApplicationTitle = "Powershell",
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline, Mandatory = $true)]
        $ToastBody
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastBody)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = $ApplicationTitle
    $Toast.Group = $ApplicationTitle
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($ApplicationTitle)
    $Notifier.Show($Toast);
}

Export-ModuleMember New-ToastNotification
