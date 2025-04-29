Add-Type -AssemblyName PresentationFramework

function Set-PowerSettings {
    param (
        [bool]$Disable
    )

    if ($Disable) {
        powercfg /change standby-timeout-ac 0
        powercfg /change standby-timeout-dc 0
        powercfg /change monitor-timeout-ac 0
        powercfg /change monitor-timeout-dc 0
        powercfg /change hibernate-timeout-ac 0
        powercfg /change hibernate-timeout-dc 0
    } else {
        powercfg /change standby-timeout-ac 15
        powercfg /change standby-timeout-dc 10
        powercfg /change monitor-timeout-ac 3
        powercfg /change monitor-timeout-dc 3
        powercfg /change hibernate-timeout-ac 30
        powercfg /change hibernate-timeout-dc 15
    }
}

function Get-PowerStatus {
    $output = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE
    $outputLines = $output -join "`n"

    # Hole die vorletzte Zeile der Ausgabe
    $lines = $outputLines.Split("`n")
    $secondLastLine = $lines[$lines.Length - 2]

    # Suche nach dem Wert "0x00000000" in der vorletzten Zeile
    if ($secondLastLine -match "0x00000000") {
        return "deaktiviert"
    } else {
        return "aktiviert"
    }
}

# Fenster
$window = New-Object System.Windows.Window
$window.Title = "StayAwake"
$window.Width = 400
$window.Height = 300
$window.WindowStartupLocation = "CenterScreen"
$window.Background = "#f9f9f9"

# Border mit abgerundeten Ecken
$border = New-Object System.Windows.Controls.Border
$border.CornerRadius = "12"
$border.Background = "#ffffff"
$border.Padding = "20"
$border.Margin = "10"
$window.Content = $border

# Layout
$stackPanel = New-Object System.Windows.Controls.StackPanel 
$stackPanel.Orientation = "Vertical"
$stackPanel.HorizontalAlignment = "Center"
$stackPanel.VerticalAlignment = "Center"
$stackPanel.Width = 300
$border.Child = $stackPanel

# Titel
$titleText = New-Object System.Windows.Controls.TextBlock
$titleText.Margin = "0,0,0,20"
$titleText.FontSize = 18
$titleText.Foreground = "#333333"
$titleText.TextAlignment = "Center"
$titleText.Text = "StayAwake"
$stackPanel.Children.Add($titleText) | Out-Null

# Button-Stil
function New-Win11Button($content, $bgColor, $borderColor) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Content = $content
    $btn.Margin = "0,8,0,0"
    $btn.Padding = "10"
    $btn.Height = 42
    $btn.FontSize = 14
    $btn.Foreground = "White"
    $btn.Background = $bgColor
    $btn.BorderBrush = $borderColor
    $btn.Cursor = "Hand"
    $btn.Template = [Windows.Markup.XamlReader]::Parse(@"
<ControlTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" TargetType="Button">
  <Border CornerRadius="8" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1">
    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
  </Border>
</ControlTemplate>
"@)
    return $btn
}

# Buttons
$enableButton = New-Win11Button "Aktiviert" "#D1D5DB" "#D1D5DB"
$disableButton = New-Win11Button "Deaktiviert" "#D1D5DB" "#D1D5DB"
$stackPanel.Children.Add($enableButton) | Out-Null
$stackPanel.Children.Add($disableButton) | Out-Null

# Statusanzeige
$statusText = New-Object System.Windows.Controls.TextBlock
$statusText.Margin = "0,20,0,10"
$statusText.FontSize = 14
$statusText.Foreground = "#0F5132"
$statusText.TextAlignment = "Center"
$stackPanel.Children.Add($statusText) | Out-Null

# Button-Farben je nach Status
function Set-ButtonState($status) {
    if ($status -eq "aktiviert") {
        $enableButton.Background = "#2563EB"
        $enableButton.BorderBrush = "#2563EB"
        $disableButton.Background = "#D1D5DB"
        $disableButton.BorderBrush = "#D1D5DB"
    } elseif ($status -eq "deaktiviert") {
        $disableButton.Background = "#2563EB"
        $disableButton.BorderBrush = "#2563EB"
        $enableButton.Background = "#D1D5DB"
        $enableButton.BorderBrush = "#D1D5DB"
    }
}

# Button-Events
$enableButton.Add_Click({
    Set-PowerSettings -Disable $false
    $statusText.Text = "Energieoptionen sind aktiviert."
    Set-ButtonState "aktiviert"
})

$disableButton.Add_Click({
    Set-PowerSettings -Disable $true
    $statusText.Text = "Energieoptionen sind deaktiviert."
    Set-ButtonState "deaktiviert"
})

# Initialstatus abfragen und setzen
$currentStatus = Get-PowerStatus
$statusText.Text = "Energieoptionen sind $currentStatus."
Set-ButtonState $currentStatus

# Fenster anzeigen
[void]$window.ShowDialog()