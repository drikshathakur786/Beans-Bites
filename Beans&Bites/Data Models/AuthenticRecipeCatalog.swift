//
//  AuthenticRecipeCatalog.swift
//  Beans&Bites
//

import Foundation

/// Comprehensive catalog of authentic hot, cold, and traditional world coffee recipes with expert pairings.
enum AuthenticRecipeCatalog {

    static func makeAllRecipes() -> [BrewRitual] {
        var rituals: [BrewRitual] = []

        // MARK: - 1. Turkish Cezve Kahve (Authentic Hot)
        let yemenMocha = CoffeeBean(
            name: "Yemen Mocha Matari",
            origin: "Yemen",
            variety: "Ancient Heirloom (Udaini)",
            process: "Natural (Dry Processed)",
            altitudeMeters: 2200,
            recommendedRoast: .dark,
            notes: [.spice, .cocoa, .caramel]
        )
        let turkishDelight = PairingItem(
            name: "Pistachio & Rose Water Turkish Delight (Lokum)",
            category: "Confection",
            accentFlavor: .floral
        )
        rituals.append(BrewRitual(
            title: "Traditional Turkish Cezve Kahve",
            subtitle: "Authentic copper pot brew with cardamom & velvet foam",
            method: .frenchPress,
            level: .intermediate,
            bean: yemenMocha,
            roast: .dark,
            pairing: turkishDelight,
            metrics: BrewMetrics(
                doseGrams: 14,
                waterMilliliters: 120,
                ratioText: "1:8.5",
                targetTimeSeconds: 165,
                temperatureCelsius: 96,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Combine Grounds & Cold Water", details: "Mix 14g powder-fine coffee with 120ml cold water and 1 crushed cardamom pod in copper cezve.", startSecond: 0, endSecond: 30, isActive: true),
                BrewStep(order: 2, title: "Gentle Low Heat Rise", details: "Heat over low flame without stirring until a rich micro-crema foam rises to the rim.", startSecond: 30, endSecond: 130),
                BrewStep(order: 3, title: "Rest and Foam Spooning", details: "Spoon the delicate crema into demitasse cup, bring to a second gentle rise, and pour unfiltered.", startSecond: 130, endSecond: 165)
            ],
            tags: [.featured, .masterclass],
            imageName: "ritual_frenchpress"
        ))

        // MARK: - 2. Ethiopian Jebena Buna (Authentic Ceremony Hot)
        let sidamaHeirloom = CoffeeBean(
            name: "Sidama Bensa Heirloom",
            origin: "Ethiopia",
            variety: "Indigenous Landraces",
            process: "Washed",
            altitudeMeters: 2150,
            recommendedRoast: .light,
            notes: [.floral, .citrus, .berry]
        )
        let bunaPopcorn = PairingItem(
            name: "Fandisha (Spiced Salted Popcorn)",
            category: "Traditional Snack",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Ethiopian Jebena Buna Ceremony",
            subtitle: "Clay pot slow-steep with frankincense aroma & jasmine sweetness",
            method: .pourOver,
            level: .master,
            bean: sidamaHeirloom,
            roast: .light,
            pairing: bunaPopcorn,
            metrics: BrewMetrics(
                doseGrams: 20,
                waterMilliliters: 300,
                ratioText: "1:15",
                targetTimeSeconds: 210,
                temperatureCelsius: 93,
                milkTemperatureCelsius: nil,
                grindSize: .medium
            ),
            steps: [
                BrewStep(order: 1, title: "Clay Pot Priming", details: "Preheat traditional clay Jebena pot over hot coals and introduce medium grounds.", startSecond: 0, endSecond: 30, isActive: true),
                BrewStep(order: 2, title: "Immersion Boil", details: "Pour boiling water into spout, let steep and gently bubble as steam rises.", startSecond: 30, endSecond: 150),
                BrewStep(order: 3, title: "Graceful High Pour", details: "Tilt Jebena smoothly from height into cini cups in a single continuous stream.", startSecond: 150, endSecond: 210)
            ],
            tags: [.featured, .morningRitual],
            imageName: "ritual_v60"
        ))

        // MARK: - 3. Mexican Café de Olla (Authentic Spiced Hot)
        let chiapasOrganic = CoffeeBean(
            name: "Chiapas Sierra Madre",
            origin: "Mexico",
            variety: "Typica & Bourbon",
            process: "Washed",
            altitudeMeters: 1600,
            recommendedRoast: .medium,
            notes: [.caramel, .spice, .cocoa]
        )
        let conchaPastry = PairingItem(
            name: "Vanilla Concha & Cinnamon Churros",
            category: "Pan Dulce",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Mexican Café de Olla",
            subtitle: "Clay pot brew simmered with raw piloncillo & Ceylon canela",
            method: .pourOver,
            level: .intermediate,
            bean: chiapasOrganic,
            roast: .medium,
            pairing: conchaPastry,
            metrics: BrewMetrics(
                doseGrams: 22,
                waterMilliliters: 330,
                ratioText: "1:15",
                targetTimeSeconds: 240,
                temperatureCelsius: 95,
                milkTemperatureCelsius: nil,
                grindSize: .mediumCoarse
            ),
            steps: [
                BrewStep(order: 1, title: "Simmer Spices & Piloncillo", details: "Dissolve unrefined piloncillo cone with Mexican Ceylon cinnamon stick and fresh orange peel in water.", startSecond: 0, endSecond: 90, isActive: true),
                BrewStep(order: 2, title: "Infuse Coarse Grounds", details: "Remove from heat, stir in Chiapas coarse grounds, cover and steep for 3 minutes.", startSecond: 90, endSecond: 210),
                BrewStep(order: 3, title: "Fine Strain into Jarrito", details: "Strain through cloth filter into traditional clay mug (jarrito de barro).", startSecond: 210, endSecond: 240)
            ],
            tags: [.seasonal, .morningRitual],
            imageName: "ritual_frenchpress"
        ))

        // MARK: - 4. Spanish Cortado Tradicional (Authentic Hot)
        let colombiaHuila = CoffeeBean(
            name: "Colombia Huila Supremo",
            origin: "Colombia",
            variety: "Caturra & Castillo",
            process: "Washed",
            altitudeMeters: 1750,
            recommendedRoast: .medium,
            notes: [.stoneFruit, .caramel, .cocoa]
        )
        let almondTurron = PairingItem(
            name: "Toasted Almond Turrón & Sea Salt Churro",
            category: "Spanish Confection",
            accentFlavor: .nutty
        )
        rituals.append(BrewRitual(
            title: "Spanish Cortado Tradicional",
            subtitle: "1:1 equal parts dense double espresso and warm silky milk",
            method: .espresso,
            level: .intermediate,
            bean: colombiaHuila,
            roast: .medium,
            pairing: almondTurron,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 36,
                ratioText: "1:2",
                targetTimeSeconds: 28,
                temperatureCelsius: 93,
                milkTemperatureCelsius: 60,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Pull Double Espresso", details: "Extract 36g of balanced, sweet stone-fruit espresso into a small Gibraltar glass.", startSecond: 0, endSecond: 28, isActive: true),
                BrewStep(order: 2, title: "Steam Silky Milk", details: "Steam 36ml whole milk to 60°C with micro-foam (less dense than cappuccino).", startSecond: 28, endSecond: 55),
                BrewStep(order: 3, title: "Cortar (Cut)", details: "Pour warm milk evenly to cut the acidity and harmonize body.", startSecond: 55, endSecond: 75)
            ],
            tags: [.morningRitual, .beginnerFriendly],
            imageName: "ritual_espresso"
        ))

        // MARK: - 5. Italian Espresso Romano (Authentic Hot / Black Coffee Pairing)
        let napoliDark = CoffeeBean(
            name: "Napoli Dark Roast Bar Blend",
            origin: "Italy / Brazil",
            variety: "Arabica & Robusta Blend",
            process: "Washed & Natural",
            altitudeMeters: 1100,
            recommendedRoast: .dark,
            notes: [.cocoa, .spice, .caramel]
        )
        let cantucciBiscotti = PairingItem(
            name: "Cantucci Tuscan Almond Biscotti & 85% Dark Cacao",
            category: "Twice-Baked Cookie",
            accentFlavor: .nutty
        )
        rituals.append(BrewRitual(
            title: "Italian Espresso Romano",
            subtitle: "Intense black espresso paired with expressed Sicilian lemon peel",
            method: .espresso,
            level: .beginner,
            bean: napoliDark,
            roast: .dark,
            pairing: cantucciBiscotti,
            metrics: BrewMetrics(
                doseGrams: 19,
                waterMilliliters: 38,
                ratioText: "1:2",
                targetTimeSeconds: 27,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Prepare Cup with Lemon Twist", details: "Rub fresh Sicilian lemon peel along the rim of a heated porcelain demitasse cup.", startSecond: 0, endSecond: 10, isActive: true),
                BrewStep(order: 2, title: "Pull Syrupy Shot", details: "Extract 38g viscous double espresso directly over the expressed essential citrus oils.", startSecond: 10, endSecond: 37),
                BrewStep(order: 3, title: "Dip & Enjoy", details: "Dip crunchy twice-baked almond biscotti into the crema to balance bitter cacao notes.", startSecond: 37, endSecond: 60)
            ],
            tags: [.masterclass, .morningRitual],
            imageName: "ritual_espresso"
        ))

        // MARK: - 6. Japanese V60 Kasuya 4:6 Method (Hot / Black Coffee Pairing)
        let panamaGeisha = CoffeeBean(
            name: "Panama Boquete Geisha",
            origin: "Panama",
            variety: "Geisha",
            process: "Natural Anaerobic",
            altitudeMeters: 1900,
            recommendedRoast: .light,
            notes: [.floral, .stoneFruit, .citrus]
        )
        let raspberryTart = PairingItem(
            name: "Fresh Raspberry Tart & Lemon Shortbread",
            category: "Tart & Cookie",
            accentFlavor: .berry
        )
        rituals.append(BrewRitual(
            title: "Japanese V60 Kasuya 4:6 Method",
            subtitle: "Award-winning clean black pour-over dialing sweetness & acidity",
            method: .v60,
            level: .master,
            bean: panamaGeisha,
            roast: .light,
            pairing: raspberryTart,
            metrics: BrewMetrics(
                doseGrams: 20,
                waterMilliliters: 300,
                ratioText: "1:15",
                targetTimeSeconds: 210,
                temperatureCelsius: 92,
                milkTemperatureCelsius: nil,
                grindSize: .mediumCoarse
            ),
            steps: [
                BrewStep(order: 1, title: "40% Sweetness Phase (Pours 1 & 2)", details: "Pour 50g water, wait 45s. Pour 70g water (120g total) to govern sweetness balance.", startSecond: 0, endSecond: 90, isActive: true),
                BrewStep(order: 2, title: "60% Strength Phase (Pours 3, 4 & 5)", details: "Divide remaining 180g water into 3 equal 60g pulses every 40 seconds.", startSecond: 90, endSecond: 175),
                BrewStep(order: 3, title: "Drawdown & Swirl", details: "Allow clean drawdown for tea-like jasmine and bergamot clarity.", startSecond: 175, endSecond: 210)
            ],
            tags: [.masterclass, .featured],
            imageName: "ritual_v60"
        ))

        // MARK: - 7. Chemex Pour-Over Elegance (Hot / Black Coffee Pairing)
        let kenyaAA = CoffeeBean(
            name: "Kenya AA Nyeri Hill",
            origin: "Kenya",
            variety: "SL28 & SL34",
            process: "Double Washed",
            altitudeMeters: 1950,
            recommendedRoast: .light,
            notes: [.berry, .citrus, .floral]
        )
        let blueberryScone = PairingItem(
            name: "Glazed Lemon Blueberry Scone",
            category: "Pastry",
            accentFlavor: .citrus
        )
        rituals.append(BrewRitual(
            title: "Chemex Pour-Over Elegance",
            subtitle: "Triple-bonded filter black brew highlighting sparkling blackcurrant acidity",
            method: .pourOver,
            level: .intermediate,
            bean: kenyaAA,
            roast: .light,
            pairing: blueberryScone,
            metrics: BrewMetrics(
                doseGrams: 30,
                waterMilliliters: 480,
                ratioText: "1:16",
                targetTimeSeconds: 270,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .mediumCoarse
            ),
            steps: [
                BrewStep(order: 1, title: "Heavy Bloom", details: "Rinse thick Chemex filter. Pour 75g water and bloom for 45s for degassing.", startSecond: 0, endSecond: 45, isActive: true),
                BrewStep(order: 2, title: "Concentric Continuous Pour", details: "Slow circular spiral pour from center outward to maintain water level at 300g.", startSecond: 45, endSecond: 150),
                BrewStep(order: 3, title: "Final Drawdown to 480g", details: "Finish pour to 480g and allow clean gravity drawdown.", startSecond: 150, endSecond: 270)
            ],
            tags: [.morningRitual, .featured],
            imageName: "ritual_v60"
        ))

        // MARK: - 8. Aeropress Inverted Champion (Hot / Black Coffee Pairing)
        let guatemalaAntigua = CoffeeBean(
            name: "Guatemala Antigua Los Volcanes",
            origin: "Guatemala",
            variety: "Red Bourbon",
            process: "Washed",
            altitudeMeters: 1650,
            recommendedRoast: .medium,
            notes: [.cocoa, .caramel, .stoneFruit]
        )
        let pecanFudge = PairingItem(
            name: "Sea Salt Caramel Fudge Pecan Brownie",
            category: "Dessert Bar",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Aeropress Inverted Champion",
            subtitle: "Full-immersion black extraction yielding red apple sweetness and praline finish",
            method: .aeropress,
            level: .intermediate,
            bean: guatemalaAntigua,
            roast: .medium,
            pairing: pecanFudge,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 200,
                ratioText: "1:11",
                targetTimeSeconds: 105,
                temperatureCelsius: 88,
                milkTemperatureCelsius: nil,
                grindSize: .mediumFine
            ),
            steps: [
                BrewStep(order: 1, title: "Inverted Setup & Fill", details: "Invert Aeropress, add 18g coffee, pour 200g water at 88°C in 15 seconds.", startSecond: 0, endSecond: 20, isActive: true),
                BrewStep(order: 2, title: "Agitate & Steep", details: "Stir paddle 3 times back-and-forth, screw on rinsed filter cap, steep until 75s.", startSecond: 20, endSecond: 75),
                BrewStep(order: 3, title: "Flip & Smooth Plunge", details: "Flip onto decanter and press with steady forearm weight for 30s until gentle hiss.", startSecond: 75, endSecond: 105)
            ],
            tags: [.competition, .morningRitual],
            imageName: "ritual_aeropress"
        ))

        // MARK: - 9. French Press Sumatra Immersion (Hot / Black Coffee Pairing)
        let sumatraMandheling = CoffeeBean(
            name: "Sumatra Mandheling Lintong",
            origin: "Indonesia",
            variety: "Ateng & Typica",
            process: "Wet Hulled (Giling Basah)",
            altitudeMeters: 1500,
            recommendedRoast: .dark,
            notes: [.cocoa, .spice, .nutty]
        )
        let darkChocolateBrioche = PairingItem(
            name: "72% Single-Origin Dark Chocolate & Cinnamon Brioche",
            category: "Pastry & Chocolate",
            accentFlavor: .cocoa
        )
        rituals.append(BrewRitual(
            title: "French Press Sumatra Immersion",
            subtitle: "Unfiltered, heavy oil black coffee with deep cedar and dark chocolate body",
            method: .frenchPress,
            level: .beginner,
            bean: sumatraMandheling,
            roast: .dark,
            pairing: darkChocolateBrioche,
            metrics: BrewMetrics(
                doseGrams: 32,
                waterMilliliters: 500,
                ratioText: "1:15.5",
                targetTimeSeconds: 300,
                temperatureCelsius: 95,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "Saturation Pour", details: "Pour all 500g boiling water over coarse grounds, ensuring total wet saturation.", startSecond: 0, endSecond: 30, isActive: true),
                BrewStep(order: 2, title: "Break the Crust", details: "At 4 minutes, gently break coffee crust with spoon and skim foam for clarity.", startSecond: 30, endSecond: 250),
                BrewStep(order: 3, title: "Filter & Pour", details: "Insert mesh plunger, lower halfway, and pour immediately to halt extraction.", startSecond: 250, endSecond: 300)
            ],
            tags: [.beginnerFriendly, .morningRitual],
            imageName: "ritual_frenchpress"
        ))

        // MARK: - 10. Kyoto Slow Drip Cold Brew (Authentic Cold / Black Coffee)
        let ethiopiaGuji = CoffeeBean(
            name: "Ethiopia Guji Uraga Natural",
            origin: "Ethiopia",
            variety: "Kurume & Dega",
            process: "Natural Anaerobic",
            altitudeMeters: 2250,
            recommendedRoast: .light,
            notes: [.berry, .floral, .stoneFruit]
        )
        let berryPavlova = PairingItem(
            name: "Wild Berry Pavlova & Vanilla Chantilly",
            category: "Dessert",
            accentFlavor: .berry
        )
        rituals.append(BrewRitual(
            title: "Kyoto Slow Drip Cold Brew",
            subtitle: "Dutch tower drop-by-drop extraction yielding winey blueberry notes",
            method: .coldBrew,
            level: .master,
            bean: ethiopiaGuji,
            roast: .light,
            pairing: berryPavlova,
            metrics: BrewMetrics(
                doseGrams: 60,
                waterMilliliters: 750,
                ratioText: "1:12.5",
                targetTimeSeconds: 28800,
                temperatureCelsius: 4,
                milkTemperatureCelsius: nil,
                grindSize: .medium
            ),
            steps: [
                BrewStep(order: 1, title: "Prep Coffee Bed & Paper Disc", details: "Layer 60g coffee in glass column, level gently and place round paper disc on top.", startSecond: 0, endSecond: 120, isActive: true),
                BrewStep(order: 2, title: "Calibrate Valve to 1 Drop / 1.5s", details: "Fill upper globe with mineral ice water; adjust brass valve to 40 drops per minute.", startSecond: 120, endSecond: 300),
                BrewStep(order: 3, title: "8-Hour Slow Extraction", details: "Allow gravity drip to pass drop-by-drop into spiral coil, concentrating aromatics.", startSecond: 300, endSecond: 28800)
            ],
            tags: [.seasonal, .masterclass],
            imageName: "ritual_kyoto"
        ))

        // MARK: - 11. Vietnamese Cà Phê Trứng (Authentic Egg Coffee)
        let vietnamRobusta = CoffeeBean(
            name: "Vietnam Dalat Peaberry Robusta",
            origin: "Vietnam",
            variety: "Robusta Peaberry",
            process: "Wet Polished",
            altitudeMeters: 1400,
            recommendedRoast: .dark,
            notes: [.cocoa, .caramel, .nutty]
        )
        let pandanWaffle = PairingItem(
            name: "Pandan Coconut Waffle & Sesame Crisp",
            category: "Sweet Street Bite",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Vietnamese Cà Phê Trứng (Egg Coffee)",
            subtitle: "Intense Phin filter brew blanketed in whipped condensed milk sabayon",
            method: .latte,
            level: .intermediate,
            bean: vietnamRobusta,
            roast: .dark,
            pairing: pandanWaffle,
            metrics: BrewMetrics(
                doseGrams: 25,
                waterMilliliters: 120,
                ratioText: "1:5",
                targetTimeSeconds: 240,
                temperatureCelsius: 96,
                milkTemperatureCelsius: 70,
                grindSize: .medium
            ),
            steps: [
                BrewStep(order: 1, title: "Phin Gravity Extraction", details: "Add dark Robusta into traditional stainless Phin filter; bloom with 20ml then brew with 100ml water.", startSecond: 0, endSecond: 120, isActive: true),
                BrewStep(order: 2, title: "Whip Egg Sabayon", details: "Whip 1 fresh egg yolk with 25ml sweetened condensed milk until fluffy, pale yellow mousse.", startSecond: 120, endSecond: 200),
                BrewStep(order: 3, title: "Layer Cream over Dark Coffee", details: "Gently ladle thick egg cream over hot or iced coffee for distinctive two-tone separation.", startSecond: 200, endSecond: 240)
            ],
            tags: [.seasonal, .featured],
            imageName: "ritual_flatwhite"
        ))

        // MARK: - 12. Italian Espresso Shakerato (Authentic Cold)
        let italianBar = CoffeeBean(
            name: "Milano Gold Espresso Blend",
            origin: "Italy / Central America",
            variety: "Highland Arabica",
            process: "Washed",
            altitudeMeters: 1700,
            recommendedRoast: .mediumDark,
            notes: [.cocoa, .caramel, .citrus]
        )
        let tiramisuTart = PairingItem(
            name: "Classic Cocoa Tiramisu Tart",
            category: "Italian Dessert",
            accentFlavor: .chocolate
        )
        rituals.append(BrewRitual(
            title: "Italian Espresso Shakerato",
            subtitle: "Double shot violently shaken with ice until thick, chilled frothy head forms",
            method: .espresso,
            level: .beginner,
            bean: italianBar,
            roast: .mediumDark,
            pairing: tiramisuTart,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 36,
                ratioText: "1:2",
                targetTimeSeconds: 25,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Pull Fresh Double Espresso", details: "Extract 36g dense espresso directly into cocktail shaker.", startSecond: 0, endSecond: 25, isActive: true),
                BrewStep(order: 2, title: "Ice & Vigorous Shake", details: "Add 1 tsp demerara syrup and 5 large dense ice cubes. Shake vigorously for 15 seconds.", startSecond: 25, endSecond: 45),
                BrewStep(order: 3, title: "Fine Strain into Coupe", details: "Double strain into a chilled Martini coupe glass; serve immediately with creamy crema head.", startSecond: 45, endSecond: 60)
            ],
            tags: [.seasonal, .masterclass],
            imageName: "ritual_espresso"
        ))

        // MARK: - 13. Artisanal Espresso Tonic (Cold / Black Coffee Hybrid)
        let costaRicaTarrazu = CoffeeBean(
            name: "Costa Rica Tarrazú Honey",
            origin: "Costa Rica",
            variety: "Caturra",
            process: "Yellow Honey",
            altitudeMeters: 1750,
            recommendedRoast: .light,
            notes: [.citrus, .floral, .stoneFruit]
        )
        let goatCheeseCrostini = PairingItem(
            name: "Whipped Goat Cheese Crostini with Fig Jam & Thyme",
            category: "Savory & Sweet Tartine",
            accentFlavor: .stoneFruit
        )
        rituals.append(BrewRitual(
            title: "Artisanal Espresso Tonic",
            subtitle: "Fizzy botanical tonic layered beneath chilled espresso and ruby grapefruit peel",
            method: .coldBrew,
            level: .intermediate,
            bean: costaRicaTarrazu,
            roast: .light,
            pairing: goatCheeseCrostini,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 180,
                ratioText: "1:10",
                targetTimeSeconds: 40,
                temperatureCelsius: 93,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Tonic & Ice Foundation", details: "Fill tall highball glass with clear artisanal ice cubes and pour 150ml chilled Indian tonic water.", startSecond: 0, endSecond: 15, isActive: true),
                BrewStep(order: 2, title: "Pull & Flash Chill Shot", details: "Pull a 36g bright citrus double espresso and cool slightly.", startSecond: 15, endSecond: 40),
                BrewStep(order: 3, title: "Float Espresso & Garnish", details: "Pour espresso slowly over inverted bar spoon to create stunning floating sunset ombre layers.", startSecond: 40, endSecond: 60)
            ],
            tags: [.seasonal, .competition],
            imageName: "ritual_kyoto"
        ))

        // MARK: - 14. Nitro Velvet Cascading Cold Brew (Cold / Black Coffee)
        let colombiaPinkBourbon = CoffeeBean(
            name: "Colombia Huila Pink Bourbon",
            origin: "Colombia",
            variety: "Pink Bourbon Rare",
            process: "Washed Thermal Shock",
            altitudeMeters: 1900,
            recommendedRoast: .medium,
            notes: [.floral, .stoneFruit, .caramel]
        )
        let toffeePretzel = PairingItem(
            name: "Smoked Sea Salt Toffee Pretzel",
            category: "Sweet & Salty Snack",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Nitro Velvet Cascading Cold Brew",
            subtitle: "Nitrogen-infused draft black coffee pouring with a Guinness-like micro-foam cascade",
            method: .coldBrew,
            level: .master,
            bean: colombiaPinkBourbon,
            roast: .medium,
            pairing: toffeePretzel,
            metrics: BrewMetrics(
                doseGrams: 70,
                waterMilliliters: 900,
                ratioText: "1:13",
                targetTimeSeconds: 57600,
                temperatureCelsius: 10,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "16-Hour Cold Steep", details: "Steep coarse Pink Bourbon grounds in chilled water for 16 hours, then triple filter.", startSecond: 0, endSecond: 300, isActive: true),
                BrewStep(order: 2, title: "Nitrogen Charge", details: "Transfer cold concentrate into siphon or keg; charge with pure N2 cartridge and shake vigorously.", startSecond: 300, endSecond: 420),
                BrewStep(order: 3, title: "Draft Cascade Pour", details: "Dispense at 45° angle into pint glass; admire the descending cream-colored nitrogen micro-cascade.", startSecond: 420, endSecond: 480)
            ],
            tags: [.masterclass, .featured],
            imageName: "ritual_kyoto"
        ))

        // MARK: - 15. Affogato al Caffè Tradizionale (Authentic Hybrid)
        let romaRoast = CoffeeBean(
            name: "Roma Dark Espresso Roast",
            origin: "Italy / Brazil",
            variety: "Bourbon & Catuaí",
            process: "Pulped Natural",
            altitudeMeters: 1300,
            recommendedRoast: .dark,
            notes: [.cocoa, .nutty, .caramel]
        )
        let amarettiMorbidi = PairingItem(
            name: "Amaretti Morbidi (Soft Italian Almond Macaroons)",
            category: "Traditional Biscuit",
            accentFlavor: .nutty
        )
        rituals.append(BrewRitual(
            title: "Affogato al Caffè Tradizionale",
            subtitle: "Scorching ristretto shot drowned over frozen artisanal Fior di Latte gelato",
            method: .espresso,
            level: .beginner,
            bean: romaRoast,
            roast: .dark,
            pairing: amarettiMorbidi,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 30,
                ratioText: "1:1.7",
                targetTimeSeconds: 22,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Scoop Gelato into Frozen Glass", details: "Place one generous scoop of artisanal Fior di Latte or vanilla bean gelato in a chilled bowl.", startSecond: 0, endSecond: 15, isActive: true),
                BrewStep(order: 2, title: "Pull Short Ristretto Shot", details: "Extract a dense, intense 30g ristretto shot into a small pouring pitcher.", startSecond: 15, endSecond: 37),
                BrewStep(order: 3, title: "Affogare (Drown)", details: "Pour boiling hot espresso table-side over the gelato and crumble almond amaretti on top.", startSecond: 37, endSecond: 60)
            ],
            tags: [.seasonal, .beginnerFriendly],
            imageName: "ritual_espresso"
        ))

        // MARK: - 16. Spanish Café con Horchata (Authentic Cold)
        let nicaraguaMaragogype = CoffeeBean(
            name: "Nicaragua Maragogype Elephant",
            origin: "Nicaragua",
            variety: "Maragogype",
            process: "Washed",
            altitudeMeters: 1550,
            recommendedRoast: .medium,
            notes: [.caramel, .nutty, .cocoa]
        )
        let cinnamonChurros = PairingItem(
            name: "Warm Cinnamon Sugar Churros",
            category: "Spanish Street Pastry",
            accentFlavor: .spice
        )
        rituals.append(BrewRitual(
            title: "Spanish Café con Horchata",
            subtitle: "Spiced chilled cold brew poured over creamy Valencia tiger nut horchata",
            method: .coldBrew,
            level: .beginner,
            bean: nicaraguaMaragogype,
            roast: .medium,
            pairing: cinnamonChurros,
            metrics: BrewMetrics(
                doseGrams: 50,
                waterMilliliters: 400,
                ratioText: "1:8",
                targetTimeSeconds: 43200,
                temperatureCelsius: 15,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "Prepare Cold Brew Concentrate", details: "Steep coarse Maragogype coffee for 12 hours for a round chocolatey concentrate.", startSecond: 0, endSecond: 60, isActive: true),
                BrewStep(order: 2, title: "Ice & Spiced Horchata", details: "Pour 120ml iced tiger nut or rice horchata spiced with cinnamon into tall glass.", startSecond: 60, endSecond: 90),
                BrewStep(order: 3, title: "Combine and Stir", details: "Float 60ml cold brew on top and dust lightly with powdered Ceylon cinnamon.", startSecond: 90, endSecond: 120)
            ],
            tags: [.seasonal, .beginnerFriendly],
            imageName: "ritual_flatwhite"
        ))

        // MARK: - 17. Japanese Flash Brew Iced V60 (Cold / Black Coffee)
        let rwandaNyamasheke = CoffeeBean(
            name: "Rwanda Nyamasheke Red Bourbon",
            origin: "Rwanda",
            variety: "Red Bourbon",
            process: "Fully Washed",
            altitudeMeters: 1850,
            recommendedRoast: .light,
            notes: [.berry, .citrus, .floral]
        )
        let mandarinFinancier = PairingItem(
            name: "Mandarin Orange Almond Financier",
            category: "Brown Butter Pastry",
            accentFlavor: .citrus
        )
        rituals.append(BrewRitual(
            title: "Japanese Flash Brew Iced V60",
            subtitle: "Hot pour-over brewed directly onto calculated ice cubes to trap volatile aromatics",
            method: .v60,
            level: .intermediate,
            bean: rwandaNyamasheke,
            roast: .light,
            pairing: mandarinFinancier,
            metrics: BrewMetrics(
                doseGrams: 22,
                waterMilliliters: 330,
                ratioText: "1:15",
                targetTimeSeconds: 150,
                temperatureCelsius: 93,
                milkTemperatureCelsius: nil,
                grindSize: .mediumFine
            ),
            steps: [
                BrewStep(order: 1, title: "Ice in Server & Bloom", details: "Place 130g dense ice cubes in server. Bloom 22g coffee with 50g hot water for 40s.", startSecond: 0, endSecond: 40, isActive: true),
                BrewStep(order: 2, title: "Concentrated Hot Pour", details: "Pour remaining 150g hot water in 2 gentle pulses directly onto coffee bed.", startSecond: 40, endSecond: 110),
                BrewStep(order: 3, title: "Instant Flash Chill", details: "Swirl server as hot coffee instantly melts the ice, locking in delicate mandarin and floral aromas.", startSecond: 110, endSecond: 150)
            ],
            tags: [.seasonal, .competition],
            imageName: "ritual_v60"
        ))

        // MARK: - 18. Australian Velvet Flat White (Specialty Hot Milk)
        let brazilCerrado = CoffeeBean(
            name: "Brazil Cerrado Single Farm",
            origin: "Brazil",
            variety: "Mundo Novo",
            process: "Natural",
            altitudeMeters: 1150,
            recommendedRoast: .medium,
            notes: [.caramel, .nutty, .cocoa]
        )
        let caramelCruffin = PairingItem(
            name: "Salted Caramel Cruffin & Hazelnut Danish",
            category: "Flaky Pastry",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Australian Velvet Flat White",
            subtitle: "Silky micro-foam textured milk folded into a short double espresso",
            method: .flatWhite,
            level: .intermediate,
            bean: brazilCerrado,
            roast: .medium,
            pairing: caramelCruffin,
            metrics: BrewMetrics(
                doseGrams: 19,
                waterMilliliters: 38,
                ratioText: "1:2",
                targetTimeSeconds: 26,
                temperatureCelsius: 93,
                milkTemperatureCelsius: 62,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Pull Double Espresso", details: "Extract 38g sweet hazelnut espresso into 180ml ceramic tulip cup.", startSecond: 0, endSecond: 26, isActive: true),
                BrewStep(order: 2, title: "Spin Micro-foam", details: "Texture whole milk to 62°C with glossy wet-paint micro-foam.", startSecond: 26, endSecond: 65),
                BrewStep(order: 3, title: "Pour Rosetta Free Pour", details: "Integrate milk smoothly from height, drop low for precise latte art finish.", startSecond: 65, endSecond: 85)
            ],
            tags: [.morningRitual, .beginnerFriendly],
            imageName: "ritual_flatwhite"
        ))

        return rituals
    }

    static func makeAllPairingGuides() -> [CoffeePairingGuide] {
        let ethiopian = CoffeeBean(
            name: "Ethiopian Yirgacheffe",
            origin: "Ethiopia",
            variety: "Heirloom",
            process: "Washed",
            altitudeMeters: 2100,
            recommendedRoast: .light,
            notes: [.citrus, .floral, .berry]
        )
        let kenya = CoffeeBean(
            name: "Kenya AA Nyeri",
            origin: "Kenya",
            variety: "SL28",
            process: "Double Washed",
            altitudeMeters: 1950,
            recommendedRoast: .light,
            notes: [.berry, .citrus, .floral]
        )
        let sumatra = CoffeeBean(
            name: "Sumatra Mandheling",
            origin: "Indonesia",
            variety: "Typica",
            process: "Wet Hulled",
            altitudeMeters: 1500,
            recommendedRoast: .dark,
            notes: [.cocoa, .spice, .nutty]
        )
        let colombia = CoffeeBean(
            name: "Colombia Huila Supremo",
            origin: "Colombia",
            variety: "Caturra",
            process: "Washed",
            altitudeMeters: 1750,
            recommendedRoast: .medium,
            notes: [.caramel, .stoneFruit, .cocoa]
        )
        let panama = CoffeeBean(
            name: "Panama Boquete Geisha",
            origin: "Panama",
            variety: "Geisha",
            process: "Natural",
            altitudeMeters: 1900,
            recommendedRoast: .light,
            notes: [.floral, .stoneFruit, .citrus]
        )

        return [
            CoffeePairingGuide(
                bean: ethiopian,
                method: .pourOver,
                pairings: [
                    PairingItem(name: "Butter Croissant", category: "Viennoiserie", accentFlavor: .caramel),
                    PairingItem(name: "Lemon Meringue Tart", category: "Citrus Dessert", accentFlavor: .citrus)
                ],
                whyItWorks: "Black Coffee Pairing: Vibrant bergamot acidity in black pourover cuts rich, flaky butter while lemon curd amplifies floral aromatics without sugar overload."
            ),
            CoffeePairingGuide(
                bean: kenya,
                method: .pourOver,
                pairings: [
                    PairingItem(name: "Glazed Blueberry Scone", category: "Pastry", accentFlavor: .berry),
                    PairingItem(name: "Dark Chocolate Raspberry Truffles", category: "Confection", accentFlavor: .chocolate)
                ],
                whyItWorks: "Black Coffee Pairing: Chemex black filter coffee eliminates oils, letting blackcurrant fruit notes sing alongside sweet baked berries and bittersweet dark cocoa."
            ),
            CoffeePairingGuide(
                bean: sumatra,
                method: .frenchPress,
                pairings: [
                    PairingItem(name: "72% Single-Origin Dark Cacao Bar", category: "Chocolate", accentFlavor: .cocoa),
                    PairingItem(name: "Warm Cinnamon Cardamom Roll", category: "Bakery", accentFlavor: .spice)
                ],
                whyItWorks: "Black Coffee Pairing: Heavy, syrupy, unfiltered black coffee needs intense bittersweet dark chocolate and warm bakery spices to tame bitterness into decadent complexity."
            ),
            CoffeePairingGuide(
                bean: colombia,
                method: .aeropress,
                pairings: [
                    PairingItem(name: "Almond Cantucci Biscotti", category: "Twice-Baked Biscuit", accentFlavor: .nutty),
                    PairingItem(name: "Sea Salt Caramel Pecan Pie", category: "Tart", accentFlavor: .caramel)
                ],
                whyItWorks: "Black Coffee Pairing: Full-immersion black extraction balances malic apple brightness with nutty almond biscotti dipped directly into the cup."
            ),
            CoffeePairingGuide(
                bean: panama,
                method: .v60,
                pairings: [
                    PairingItem(name: "Vanilla Bean Shortbread", category: "Cookie", accentFlavor: .floral),
                    PairingItem(name: "White Peach Financier", category: "Almond Pastry", accentFlavor: .stoneFruit)
                ],
                whyItWorks: "Black Coffee Pairing: Delicate tea-like black Geisha should never be masked by heavy dairy; it shines best with subtle stone fruit and buttery almond pastries."
            )
        ]
    }
}
