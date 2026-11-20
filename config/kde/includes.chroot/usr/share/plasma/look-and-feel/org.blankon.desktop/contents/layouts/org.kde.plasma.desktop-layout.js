loadTemplate("org.kde.plasma.desktop.defaultPanel")

var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var widgets = allPanels[i].widgets();
    for (var k = 0; k < widgets.length; k++) {
        if (widgets[k].type === "org.kde.plasma.kickoff") {
            widgets[k].currentConfigGroup = ["General"];
            widgets[k].writeConfig("icon", "start-here-blankon-symbolic");
        }
    }
}

var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
    desktopsArray[j].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktopsArray[j].writeConfig("Image", "file:///usr/share/wallpapers/sinambung/");
}
