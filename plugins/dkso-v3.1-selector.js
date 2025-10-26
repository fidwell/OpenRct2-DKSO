"use strict";

const dksoGroups = [
    "fidwell.v3.1.scenery_group.trees_dkso",
    "fidwell.v3.scenery_group.shrubs_dkso",
    "fidwell.v3.scenery_group.gardens_dkso",
    "fidwell.v3.1.scenery_group.fences_dkso",
    "fidwell.v3.scenery_group.walls_dkso",
    "rct2.scenery_group.scgpathx",
    "fidwell.v3.scenery_group.abstract_dkso",
    "fidwell.v3.scenery_group.classical_dkso",
    "fidwell.v3.scenery_group.egyptian_dkso",
    "fidwell.v3.scenery_group.creepy_dkso",
    "fidwell.v3.scenery_group.jungle_dkso",
    "fidwell.v3.scenery_group.jurassic_dkso",
    "fidwell.v3.scenery_group.martian_dkso",
    "fidwell.v3.scenery_group.medieval_dkso",
    "fidwell.v3.scenery_group.mine_dkso",
    "fidwell.v3.scenery_group.pagoda_dkso",
    "fidwell.v3.1.scenery_group.snow_dkso",
    "fidwell.v3.scenery_group.space_dkso",
    "fidwell.v3.scenery_group.spooky_dkso",
    "rct2.scenery_group.scgurban",
    "fidwell.v3.scenery_group.wonderland_dkso",
    "fidwell.v3.scenery_group.mechanical_dkso",
    "fidwell.v3.scenery_group.ggarden_dkso",
    "fidwell.v3.scenery_group.water_dkso",
    "fidwell.v3.scenery_group.pirates_dkso",
    "fidwell.v3.scenery_group.sports_dkso",
    "fidwell.v3.scenery_group.wildwest_dkso",
    "fidwell.v3.scenery_group.gcandy_dkso",
    "fidwell.v3.scenery_group.africa_dkso",
    "fidwell.v3.scenery_group.antarctic_dkso",
    "fidwell.v3.scenery_group.asia_dkso",
    "fidwell.v3.scenery_group.australasia_dkso",
    "fidwell.v3.scenery_group.europe_dkso",
    "fidwell.v3.1.scenery_group.namerica_dkso",
    "fidwell.v3.1.scenery_group.samerica_dkso",
    "fidwell.v3.scenery_group.darkage_dkso",
    "fidwell.v3.scenery_group.future_dkso",
    "fidwell.v3.scenery_group.mythological_dkso",
    "fidwell.v3.scenery_group.prehistoric_dkso",
    "fidwell.v3.scenery_group.twenties_dkso",
    "fidwell.v3.scenery_group.twentieswall_dkso",
    "fidwell.v3.scenery_group.rocknroll_dkso",
    "fidwell.v3.scenery_group.panda_dkso",
    "fidwell.v3.scenery_group.sixflags_dkso"
];

const select = function () {
    console.log("Removing all scenery groups...");
    const oldGroups = objectManager.getAllObjects("scenery_group");
    for (var g = 0; g < oldGroups.length; g++) {
        objectManager.unload(oldGroups[g].identifier);
    }

    console.log("Adding new scenery groups...");
    for (var g = 0; g < dksoGroups.length; g++) {
        objectManager.load(dksoGroups[g]);
    }

    console.log("Adding new objects...");
    const newGroups = objectManager.getAllObjects("scenery_group");
    for (var g = 0; g < newGroups.length; g++) {
        for (var i = 0; i < newGroups[g].items.length; i++) {
            objectManager.load(newGroups[g].items[i]);
        }
    }
};

registerPlugin({
    name: "DKSO v3 Selector",
    version: "1.0",
    authors: ["fidwell"],
    type: "local",
    licence: "MIT",
    targetApiVersion: 108,
    main: function () {
        ui.registerMenuItem("DKSO v3.1 Selector", select);
    }
});
