Config = {}

Config = {

    --------------------------------------------------
    --------- Config Logs
    --------------------------------------------------

    logs = {

        ---- Point menu

        Armurerie = "",
        Boss = "",
        Camera = "",
        Casier = "",
        CoffreObjets = "",
        CoffreArmes = "",
        AcceuilPolice = "",
        GestionPermis = "",
        CasierPolice = "",
        GavPolice = "",

        ---------------- F6 & Co

        PriseFinService = "",
        AvisDeRecherche = "",
        Objets = "",
        FactureAmende = "",
        Fouille = "",

    },

    --------------------------------------------------
    --------- Config Général
    --------------------------------------------------

    deleteContent = true, -- Supprimer le contenu du casier après l'avoir retire
    
    ColorMenuR = 103, -- Bannière couleur R -- Couleur du menu
    ColorMenuG = 118, -- Bannière couleur G -- Couleur du menu
    ColorMenuB = 236, -- Bannière couleur B -- Couleur du menu
    ColorMenuA = 150, -- Bannière couleur A -- Opacité du menu

    blip = {
        name = "L.S.P.D",
        sprite = 60,
        color = 29,
        position = {x = 439.14, y = -982.3, z = 30.69},
        scale = 0.8,
    },

    Marker = {
        type = 6,
        drawdistance = 20,
    },

    armurerie = {
        {nom = "Pistolet", arme = "weapon_pistol", minimum_grade = 0, restockprice = 300},
        {nom = "Fusil à pompe", arme = "weapon_pumpshotgun_mk2", minimum_grade = 0, restockprice = 500},
        {nom = "M4", arme = "weapon_carbinerifle", minimum_grade = 0, restockprice = 600}
    },

    amountAmmo = 200, -- for armurerie
    armesEnItems = false, -- for armurerie

    spawn = {
        spawnvoiture = {position = {x = 452.38, y = -989.59, z = 25.7, h = 1.07}},
        spawnheli = {position = {x = 448.69, y = -981.65, z = 43.69, h = 87.916}},
        spawnbato = {position = {x = 452.38, y = -989.59, z = 25.7, h = 1.07}}
    },

    HelicoCamAndCo = "polmav",

    --------------------------------------------------
    --------- Permissions & Co
    --------------------------------------------------

    JobName = "police",
    SocietyName = "society_police",
    esxGet = "esx:getSharedObject",


    -- il y'a 7 grades 
    -- For points
    GradePointBoss = 7, 
    GradePointArmu = 1, 
    GradePointBracelet = 1,
    GradePointCamera = 1,
    GradePointCasier = 1,
    GradePointCoffre = 1, 
    GradePointGarage = 1, 
    GradePointGarageHeli = 1,
    GradePointGarageBateau = 1,
    GradePointGestionPermis = 1, 
    GradePointBaseDeDonne = 1, 
    GradePointVestiaire = 1, 
    GradePointExtra = 1,

    -- F6
    GradeMenuAvisDeRecherche = 1,
    GradeMenuObjets = 1, 
    GradeMenuChien = 1, 
    GradeMenuIntervention = 1, 
    -- F6
    GradeMenuFouille = 1, 
    GradeMenuLicences = 1,
    GradeMenuAlcool = 1,
    GradeMenuDrugs = 1,
    GradeMenuRadar = 1,
    GradeMenuMegaphone = 1,
    -- Coffre
    GradeRetrait = 1,
    GradeDepot = 1,
    -- Other
    GradePourCameraHelico = 1,
    --------------------------------------------------
    --------- Intérvention
    --------------------------------------------------

    vehicle1 = 'riot',
    vehicle2 = 'policeb',
    vehicle3 = 'policet',
    vehicle4 = 'bmx',
    vehicle5 = 'polmav',
    ped1 = 's_m_y_cop_01',
    ped2 = 's_m_y_cop_01',
    ped3 = 's_m_y_cop_01',
    ped4 = 's_m_y_cop_01',
    ped5 = 's_m_y_cop_01',
    ped6 = 's_m_y_cop_01',
    weapon1 = 'WEAPON_CARBINERIFLE',
    weapon2 = 'WEAPON_PISTOL',
    weapon3 = 'WEAPON_SMG',
    weapon4 = 'WEAPON_STUNGUN',
    weapon6 = 'WEAPON_STUNGUN',

}

--------------------------------------------------
--------- Position des points
--------------------------------------------------

Config.pos = {
	garagevoiture = {position = {x = 459.90, y = -986.70, z = 25.69, h = 96.0}},
	garageheli = {position = {x = 458.92, y = -998.93, z = 25.7, h = 28.64}},
    garagebateau = {position = {x = 458.21, y = -991.56, z = 25.7, h = 199.23}},
	armurerie = {position = {x = 478.89, y = -996.79, z = 30.68, h = 92.89}},
	vestiaire = {position = {x = 462.12, y = -996.43, z = 30.69}},
    coffre = {position = {x = 449.91, y = -996.77, z = 30.68}},
    boss = {position = {x = 460.72, y = -985.55, z = 30.72}},
    plainterdv = {position = {x = 440.94, y = -981.69, z = 29.68}},
    casierjudiciaire = {position = {x = 453.80, y = -988.09, z = 30.68}},
    cameraview = {position = {x = 454.24, y = -982.15, z = 30.69}},
    menuPermisInfo = {position = {x = 453.9, y = -977.5, z = 29.69}},
    bracelet = {position = {x = 450.08, y = -987.53, z = 30.69}},
    menuVerifBdd = {position = {x = 454.39, y = -985.22, z = 30.69}},
    tenueGav = {position = {x = 450.19, y = -980.82, z = 30.69}},
    extrascustom = {position = {x = 450.0, y = -975.74, z = 25.7}}
}



--------------------------------------------------
--------- Tenues/véhicules 
--------------------------------------------------

police = {
    clothes = {
        specials = {
            [0] = {
                label = "Reprendre sa tenue civil",
                minimum_grade = 0, -- grade minmum pour prendre la tenue
                variations = {male = {}, female = {}},
                onEquip = function()
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                        TriggerEvent('skinchanger:loadSkin', skin)
                    end)
                    SetPedArmour(PlayerPedId(), 0)
                end
            },
            [1] = {
                label = "Tenue Police",
                minimum_grade = 0, -- grade minmum pour prendre la tenue
                variations = {
                    male = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 39, ['tshirt_2'] = 0,
                        ['torso_1'] = 55, ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 46, ['pants_2'] = 0,
                        ['shoes_1'] =25, ['shoes_2'] = 0,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    },
                    female = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 15,['tshirt_2'] = 2,
                        ['torso_1'] = 65, ['torso_2'] = 2,
                        ['arms'] = 36, ['arms_2'] = 0,
                        ['pants_1'] = 38, ['pants_2'] = 2,
                        ['shoes_1'] = 12, ['shoes_2'] = 6,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    }
                },
                onEquip = function()  
                end
            },
            [2] = {
                label = "Tenue Officier",
                minimum_grade = 1, -- grade minmum pour prendre la tenue
                variations = {
                    male = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 39, ['tshirt_2'] = 0,
                        ['torso_1'] = 55, ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 46, ['pants_2'] = 0,
                        ['shoes_1'] =25, ['shoes_2'] = 0,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    },
                    female = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 15,['tshirt_2'] = 2,
                        ['torso_1'] = 65, ['torso_2'] = 2,
                        ['arms'] = 36, ['arms_2'] = 0,
                        ['pants_1'] = 38, ['pants_2'] = 2,
                        ['shoes_1'] = 12, ['shoes_2'] = 6,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    }
                },
                onEquip = function()  
                end
            },
            [3] = {
                label = "Tenue Sergent",
                minimum_grade = 2, -- grade minmum pour prendre la tenue
                variations = {
                    male = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 39, ['tshirt_2'] = 0,
                        ['torso_1'] = 55, ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 46, ['pants_2'] = 0,
                        ['shoes_1'] =25, ['shoes_2'] = 0,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    },
                    female = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 15,['tshirt_2'] = 2,
                        ['torso_1'] = 65, ['torso_2'] = 2,
                        ['arms'] = 36, ['arms_2'] = 0,
                        ['pants_1'] = 38, ['pants_2'] = 2,
                        ['shoes_1'] = 12, ['shoes_2'] = 6,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    }
                },
                onEquip = function()  
                end
            },
            [4] = {
                label = "Tenue Lieutenant",
                minimum_grade = 3, -- grade minmum pour prendre la tenue
                variations = {
                    male = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 39, ['tshirt_2'] = 0,
                        ['torso_1'] = 55, ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 46, ['pants_2'] = 0,
                        ['shoes_1'] =25, ['shoes_2'] = 0,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    },
                    female = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 15,['tshirt_2'] = 2,
                        ['torso_1'] = 65, ['torso_2'] = 2,
                        ['arms'] = 36, ['arms_2'] = 0,
                        ['pants_1'] = 38, ['pants_2'] = 2,
                        ['shoes_1'] = 12, ['shoes_2'] = 6,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    }
                },
                onEquip = function()  
                end
            },
            [5] = {
                label = "Tenue Directeur",
                minimum_grade = 4, -- grade minmum pour prendre la tenue
                variations = {
                    male = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 39, ['tshirt_2'] = 0,
                        ['torso_1'] = 55, ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 46, ['pants_2'] = 0,
                        ['shoes_1'] =25, ['shoes_2'] = 0,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    },
                    female = {
                        ['bags_1'] = 0, ['bags_2'] = 0,
                        ['tshirt_1'] = 15,['tshirt_2'] = 2,
                        ['torso_1'] = 65, ['torso_2'] = 2,
                        ['arms'] = 36, ['arms_2'] = 0,
                        ['pants_1'] = 38, ['pants_2'] = 2,
                        ['shoes_1'] = 12, ['shoes_2'] = 6,
                        ['mask_1'] = 0, ['mask_2'] = 0,
                        ['bproof_1'] = 0,
                        ['chain_1'] = 0,
                        ['helmet_1'] = -1, ['helmet_2'] = 0,
                    }
                },
                onEquip = function()  
                end
            }
        },
        grades = {
            [0] = {
                label = "Mettre",
                minimum_grade = 0, -- grade minmum pour prendre la tenue
                variations = {
                male = {
                    ['bproof_1'] = 1,
                },
                female = {
                    ['bproof_1'] = 1,
                }
            },
            onEquip = function()
            end
        },
		[1] = {
			label = "Enlever",
			minimum_grade = 0, -- grade minmum pour prendre la tenue
			variations = {
			male = {
				['bproof_1'] = 0,
			},
			female = {
				['bproof_1'] = 0,
			}
		},
		onEquip = function()
		end
	},
    }
},
	vehicles = {                                                         -- category = Separator en rageui 
        car = {                                                           -- Label = nom ig qui apparaitra sur le bouton 
            {category = "↓ ~b~Véhicule(s) ~s~↓"},                           -- Model = nom de spawn du véhicule
            {model = "sultan", label = "Sultan d'entrainement", minimum_grade = 0, restockprice = 1000},
            {model = "police2", label = "POLICE TEST", minimum_grade = 0, restockprice = 1000},
            {model = "code3c8lcb", label = "Corvette de course", minimum_grade = 0, restockprice = 1000}, --minimum_grade = grade minmum pour prendre
			{model = "code3cvpilcb", label = "Ford Police", minimum_grade = 0, restockprice = 5000},
            {model = "code3demonlcb", label = "Dodge Demon", minimum_grade = 0, restockprice = 10000},
            {model = "code3f150k9lcb", label = "Ford 150 K-9", minimum_grade = 0, restockprice = 12000},
            {model = "code3f150lcb", label = "Ford 150 K-9 V2", minimum_grade = 0, restockprice = 12000},
            {model = "code3impalalcb", label = "Chevrolet Impala", minimum_grade = 0, restockprice = 12000},
            {model = "code3mustanglcb", label = "Ford Mustang GT", minimum_grade = 0, restockprice = 12000},
            {model = "code3ramlcb", label = "Dodge RAM", minimum_grade = 0, restockprice = 12000},
            {model = "code3zl1lcb", label = "Chevrolet ZL1", minimum_grade = 0, restockprice = 12000},
            {model = "code314chargerlcb", label = "Dodge Charger Banalisé", minimum_grade = 0, restockprice = 12000},
            {model = "code314tahoelcb", label = "Dodge Tahoe", minimum_grade = 0, restockprice = 12000},
            {model = "code316fpiuk9lcb", label = "Ford Police Intervention", minimum_grade = 0, restockprice = 12000},
            {model = "code316fpiulcb", label = "Ford Police Intervention 2", minimum_grade = 0, restockprice = 12000}
        },
        helico = {
            {category = "↓ ~b~Hélicoptère(s) ~s~↓"},                           -- Model = nom de spawn du véhicule
            {model = "polmav", label = "Hélico du LSPD", minimum_grade = 0, restockprice = 1000}
        },
        bateaux = {
            {category = "↓ ~b~Bateau(x) ~s~↓"},                           -- Model = nom de spawn du véhicule
            {model = "predator", label = "Predator du LSPD", minimum_grade = 0, restockprice = 1000}
        }
    }
}