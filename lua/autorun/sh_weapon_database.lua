WeaponDatabase = {}
WeaponDatabase.Raw = {
    rifles = {
        "m9k_acr",
        "mac_bo2_an94",
        "m9k_auga3",
	    "mac_codww2_stg",
	    "mac_codww2_m1g",
        "robotnik_bo1_com",
        "robotnik_bo1_en",
        "robotnik_mw2_f2",
        "mac_bo2_falosw",
        "robotnik_bo1_g11",
        "m9k_fal",
        "robotnik_bo1_gal",
        "robotnik_bo1_hk",
        "m9k_m16a4_acog",
        "mac_bo2_hk416",
        "robotnik_mw2_m4",
        "mac_bo2_m8a1",
        "mac_bo2_mtar",
        "mac_bo2_pdw",
        "mac_bo2_smr",
        "robotnik_bo1_stn",
        "mac_bo2_swat",
        "robotnik_mw2_tar",
        "mac_bo2_type25",
        "tfa_ak74",
        "m9k_m4a1",
        "m9k_scar",
        "m9k_g3a3",
        "m9k_g36",
        "m9k_l85",
        "cw_vss",
        "m9k_m14sp",
        "m9k_famas",
    },
    machinegun = {
        "mac_bo2_hamr",
        "robotnik_mw2_lsw",
        "mac_codww2_bren",
        "mac_codww2_mg42",
        "mac_codww2_lew",
        "mac_bo2_lsat",
        "robotnik_mw2_240",
        "robotnik_mw2_mg4",
        "m9k_m60",
        "mac_bo2_mk48",
        "mac_bo2_qbblsw",
        "robotnik_mw2_rpd",
        "robotnik_bo1_rpk",
    },
    pistols = {
        "m9k_deagle",
        "m9k_colt1911",
        "mac_codww2_no2",
        "robotnik_bo1_mak",
        "cw_mr96",
        "cw_p99",
        "cw_fiveseven",
        "robotnik_mw2_44",
        "robotnik_bo1_asp",
        "mac_bo2_b23r",
        "robotnik_bo1_cz",
        "mac_bo2_exec",
        "mac_bo2_kard",
        "m9k_coltpython",
        "mac_bo2_tac45",
        "robotnik_mw2_usp",
        "m9k_glock",
    },
    smg = {
        "mac_bo2_chicom",
        "m9k_thompson",
        "m9k_mp40",
        "mac_codww2_ppsh",
        "robotnik_bo1_ki",
        "robotnik_mw2_mp5",
        "robotnik_bo1_mpl",
        "m9k_mp7",
        "mac_bo2_msmc",
        "m9k_smgp90",
        "mac_bo2_peacekpr",
        "robotnik_bo1_pm",
        "robotnik_mw2_pp",
        "mac_bo2_scorp",
        "robotnik_bo1_skrp",
        "robotnik_bo1_spc",
        "robotnik_mw2_tmp",
        "m9k_uzi",
        "m9k_vector",
        "m9k_ump45",
        "m9k_mp5",
        "robotnik_bo1_m11",
    },
    shotgun = {
        "robotnik_mw2_aa12",
        "m9k_browningauto5",
        "robotnik_bo1_h10",
        "mac_bo2_ksg",
        "robotnik_mw2_m10",
        "robotnik_mw2_87",
        "mac_bo2_m1216",
        "robotnik_bo1_ol",
        "robotnik_mw2_rngr",
        "mac_codww2_sawed",
        "mac_bo2_870",
        "mac_bo2_s12",
        "m9k_spas12",
        "robotnik_mw2_stkr",
        "m9k_mossberg590",
        "m9k_m3",
    },
    sniper = {
        "mac_bo2_ballista",
        "robotnik_mw2_brt",
        "mac_codww2_karb",
        "mac_codww2_smle",
        "mac_bo2_dsr50",
        "robotnik_mw2_int",
        "m9k_dragunov",
        "m9k_aw50",
        "robotnik_mw2_ebr",
        "m9k_psg1",
        "mac_bo2_svu",
        "robotnik_bo1_wa",
    },
    special = {
        "tfa_doom_gauss",
        "tfa_ins2_codol_free",
        "tfa_ins2_volk",
        "mac_bo2_crssbw_f",
        "tfa_dax_big_glock",
        "tfa_cso_magnum_lancer",
        "infinitygunx99",
        "weapon_gluongun",
        "weapon_bms_gluon",
    },
    gloves = {
        "specialist"
    }
}
WeaponDatabase.Nice = {}

if CLIENT then
local path = "asapf4/weapon_customs/classes/"
WeaponDatabase.Categories = {
    rifles = {
        name = "Assault Rifles",
        icon = Material(path .. "rifles.png"),
        color = Color(255, 126, 48),
        order = 1
    },
    smg = {
        name = "SMGs",
        icon = Material(path .. "smg.png"),
        color = Color(155, 255, 48),
        order = 2
    },
    sniper = {
        name = "Sniper Rifles",
        icon = Material(path .. "sniper.png"),
        color = Color(48, 248, 255),
        order = 4
    },
    shotgun = {
        name = "Shotguns",
        icon = Material(path .. "shotgun.png"),
        color = Color(77, 48, 255),
        order = 5
    },
    pistols = {
        name = "Pistols",
        icon = Material(path .. "pistol.png"),
        color = Color(228, 48, 255),
        order = 6
    },
    machinegun = {
        name = "Machine Guns",
        icon = Material(path .. "machine.png"),
        color = Color(255, 48, 48),
        order = 7
    },
    special = {
        name = "Specials",
        icon = Material(path .. "any.png"),
        color = Color(255, 223, 48),
        order = 8
    },
    gloves = {
        name = "Gloves",
        icon = Material(path .. "glove.png"),
        isGloves = true,
        color = Color(255, 150, 150),
        order = 9
    }
}
end

function WeaponDatabase:Add(cat, class)
    self.Weapons[cat] = class
end

function WeaponDatabase:ProcessDatabase()
    local data = {}
    local i = 0
    for cat,weps in pairs(self.Raw) do
        for k,v in pairs(weps) do
            local info = weapons.GetStored(v)
            --MsgN(v)
            self.Nice[v] = info
            i = i + 1
        end
    end
end

timer.Simple(0.1, function()
    WeaponDatabase:ProcessDatabase()
end)

