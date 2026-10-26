//
//  AuthenticRecipeCatalog.swift
//  Beans&Bites
//

import Foundation

/// Comprehensive catalog of authentic hot, cold, and trending coffee recipes with a special focus on the Indian market and popular global styles.
enum AuthenticRecipeCatalog {

    static func makeAllRecipes() -> [BrewRitual] {
        var rituals: [BrewRitual] = []

        // MARK: - 1. South Indian Filter Kaapi (Degree Coffee)
        let chikmagalurPeaberry = CoffeeBean(
            name: "Chikmagalur Peaberry & Chicory Blend",
            origin: "Karnataka, India",
            variety: "Peaberry & Chicory (80:20)",
            process: "Washed & Roasted Chicory",
            altitudeMeters: 1250,
            recommendedRoast: .dark,
            notes: [.caramel, .cocoa, .spice]
        )
        let meduVadaPairing = PairingItem(
            name: "Crispy Medu Vada & Mysore Pak",
            category: "Traditional South Indian Bite",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Traditional South Indian Filter Kaapi",
            subtitle: "Authentic brass filter decoction with frothy hot boiled milk & chicory richness",
            method: .frenchPress,
            level: .intermediate,
            bean: chikmagalurPeaberry,
            roast: .dark,
            pairing: meduVadaPairing,
            metrics: BrewMetrics(
                doseGrams: 20,
                waterMilliliters: 100,
                ratioText: "1:5",
                targetTimeSeconds: 180,
                temperatureCelsius: 96,
                milkTemperatureCelsius: 75,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Decoction Extraction", details: "Add 20g of 80:20 coffee powder into the upper chamber of a traditional stainless/brass filter. Press disc lightly, pour 100ml boiling water, and let the thick first decoction drip.", startSecond: 0, endSecond: 90, isActive: true),
                BrewStep(order: 2, title: "Boil Full-Cream Milk", details: "Heat 120ml whole milk to a rolling boil until rich, natural micro-foam forms on top.", startSecond: 90, endSecond: 140),
                BrewStep(order: 3, title: "Meter Kaapi Aerial Pour", details: "Combine 30ml decoction with hot milk & sugar in a dabarah. Pour back and forth between dabarah and tumbler from an arm's height to generate thick aromatic foam.", startSecond: 140, endSecond: 180)
            ],
            tags: [.featured, .morningRitual],
            imageName: "ritual_frenchpress",
            isSaved: true,
            isFeatured: true
        ))

        // MARK: - 2. Desi Pheti Hui Coffee (Indian Beaten Coffee)
        let indianGoldRoast = CoffeeBean(
            name: "Indian Gold Roast Blend",
            origin: "Coorg / Chikmagalur, India",
            variety: "Arabica & Robusta Blend",
            process: "Estate Roasted",
            altitudeMeters: 1100,
            recommendedRoast: .mediumDark,
            notes: [.caramel, .cocoa, .nutty]
        )
        let bunMaskaPairing = PairingItem(
            name: "Warm Buttered Bun Maska & Parle-G",
            category: "Iconic Irani Café Bite",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Desi Pheti Hui Coffee",
            subtitle: "Hand-whipped golden cream topped with steaming hot milk — the Indian street-style cappuccino",
            method: .latte,
            level: .beginner,
            bean: indianGoldRoast,
            roast: .mediumDark,
            pairing: bunMaskaPairing,
            metrics: BrewMetrics(
                doseGrams: 10,
                waterMilliliters: 150,
                ratioText: "1:15",
                targetTimeSeconds: 150,
                temperatureCelsius: 85,
                milkTemperatureCelsius: 70,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "The Desi Whip", details: "In a mug, beat 2 tsp coffee powder, 2 tsp sugar, and 1 tbsp warm water with a spoon for 3 minutes until it turns into a pale golden, fluffy mousse.", startSecond: 0, endSecond: 90, isActive: true),
                BrewStep(order: 2, title: "Steam Milk Hot", details: "Heat 150ml creamy whole milk until steaming and bubbly.", startSecond: 90, endSecond: 120),
                BrewStep(order: 3, title: "Cloud Pour & Rise", details: "Pour hot milk from height into the whipped cream; gently stir the bottom so the thick velvety mousse cloud rises on top.", startSecond: 120, endSecond: 150)
            ],
            tags: [.featured, .beginnerFriendly],
            imageName: "ritual_latte",
            isSaved: true
        ))

        // MARK: - 3. Coastal Tender Coconut Cold Brew (Daab Nariyal Cold Brew)
        let monsoonMalabarLight = CoffeeBean(
            name: "Monsoon Malabar AA Coastal",
            origin: "Malabar Coast, India",
            variety: "Arabica Monsooned",
            process: "Monsoon Natural",
            altitudeMeters: 1100,
            recommendedRoast: .medium,
            notes: [.nutty, .spice, .caramel]
        )
        let tenderCoconutPairing = PairingItem(
            name: "Coconut Jaggery Tea Cake & Nankhatai",
            category: "Artisanal Bakery Bite",
            accentFlavor: .nutty
        )
        rituals.append(BrewRitual(
            title: "Coastal Tender Coconut Cold Brew",
            subtitle: "Fresh sweet daab coconut water topped with chilled single-origin cold brew — Subko & Blue Tokai favorite",
            method: .coldBrew,
            level: .beginner,
            bean: monsoonMalabarLight,
            roast: .medium,
            pairing: tenderCoconutPairing,
            metrics: BrewMetrics(
                doseGrams: 25,
                waterMilliliters: 200,
                ratioText: "1:8",
                targetTimeSeconds: 120,
                temperatureCelsius: 10,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "Fresh Daab Water & Ice", details: "Fill a highball glass with dense ice and pour 140ml fresh sweet South Indian tender coconut water.", startSecond: 0, endSecond: 30, isActive: true),
                BrewStep(order: 2, title: "Slow Spoon Float", details: "Float 60ml chilled bold Monsoon Malabar cold brew concentrate over an inverted bar spoon to build sunset ombre layers.", startSecond: 30, endSecond: 90),
                BrewStep(order: 3, title: "Malai Garnish", details: "Garnish with a sliver of soft tender coconut malai; stir gently for an electrolyte-rich, naturally sweet tropical sip.", startSecond: 90, endSecond: 120)
            ],
            tags: [.seasonal, .featured],
            imageName: "ritual_kyoto",
            isSaved: true
        ))

        // MARK: - 4. Monsoon Malabar French Press (GI Heritage Brew)
        let monsoonMalabarReserve = CoffeeBean(
            name: "Monsoon Malabar AA Special Reserve",
            origin: "Karnataka & Kerala, India",
            variety: "S795 & Kent Monsooned",
            process: "3-Month Ocean Wind Seasoned",
            altitudeMeters: 1150,
            recommendedRoast: .dark,
            notes: [.cocoa, .spice, .nutty]
        )
        let shrewsburyPairing = PairingItem(
            name: "Pune Shrewsbury Butter Biscuits",
            category: "Heritage Bakery Cookie",
            accentFlavor: .caramel
        )
        rituals.append(BrewRitual(
            title: "Monsoon Malabar French Press",
            subtitle: "GI-tagged heritage brew exposed to Arabian Sea winds — low acidity with heavy dark chocolate & cedar oils",
            method: .frenchPress,
            level: .intermediate,
            bean: monsoonMalabarReserve,
            roast: .dark,
            pairing: shrewsburyPairing,
            metrics: BrewMetrics(
                doseGrams: 24,
                waterMilliliters: 360,
                ratioText: "1:15",
                targetTimeSeconds: 240,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "Monsoon Bloom", details: "Saturate 24g coarse grounds with 80ml water at 94°C for 45 seconds to release cedar aromatics.", startSecond: 0, endSecond: 45, isActive: true),
                BrewStep(order: 2, title: "Full Immersion Steep", details: "Fill remaining 280ml water, stir the coffee crust twice, cover with plunger and steep for 3 minutes.", startSecond: 45, endSecond: 210),
                BrewStep(order: 3, title: "Velvet Plunge", details: "Slowly press down the mesh plunger and pour for an ultra-low acid, syrupy dark chocolate brew.", startSecond: 210, endSecond: 240)
            ],
            tags: [.masterclass, .featured],
            imageName: "ritual_frenchpress"
        ))

        // MARK: - 5. Karupatti / Sukku Masala Kaapi (Spiced Palm Jaggery Herbal Brew)
        let coorgRobusta = CoffeeBean(
            name: "Coorg Robusta & Arabica Roast",
            origin: "Kodagu (Coorg), India",
            variety: "Cauvery & Robusta",
            process: "Shade Grown Natural",
            altitudeMeters: 1100,
            recommendedRoast: .dark,
            notes: [.spice, .cocoa, .caramel]
        )
        let chikkiPairing = PairingItem(
            name: "Sesame Peanut Chikki & Banana Chips",
            category: "Traditional Spiced Snack",
            accentFlavor: .spice
        )
        rituals.append(BrewRitual(
            title: "Karupatti / Sukku Masala Kaapi",
            subtitle: "Chettinad Ayurvedic spiced brew with organic palm jaggery, dry ginger & crushed black pepper",
            method: .pourOver,
            level: .beginner,
            bean: coorgRobusta,
            roast: .dark,
            pairing: chikkiPairing,
            metrics: BrewMetrics(
                doseGrams: 16,
                waterMilliliters: 240,
                ratioText: "1:15",
                targetTimeSeconds: 210,
                temperatureCelsius: 96,
                milkTemperatureCelsius: nil,
                grindSize: .mediumCoarse
            ),
            steps: [
                BrewStep(order: 1, title: "Simmer Jaggery & Spices", details: "Boil 240ml water with 20g crushed organic palm jaggery (karupatti), dry ginger (sukku), black peppercorns, and cardamom until dissolved.", startSecond: 0, endSecond: 90, isActive: true),
                BrewStep(order: 2, title: "Infuse Coffee Grounds", details: "Stir in 16g dark coffee grounds, lower flame, and simmer gently for 2 minutes as natural spices infuse.", startSecond: 90, endSecond: 180),
                BrewStep(order: 3, title: "Brass Strain into Tumbler", details: "Strain through a fine cloth or brass filter into a clay cup; enjoy soothing, immunity-boosting digestive warmth.", startSecond: 180, endSecond: 210)
            ],
            tags: [.seasonal, .morningRitual],
            imageName: "ritual_v60"
        ))

        // MARK: - 6. Subko-Style Orange Tonic Espresso
        let arakuOrganic = CoffeeBean(
            name: "Araku Valley Tribal Organic",
            origin: "Araku Valley, India",
            variety: "Selection 9 & Chandragiri",
            process: "Honey Processed",
            altitudeMeters: 1250,
            recommendedRoast: .medium,
            notes: [.citrus, .stoneFruit, .cocoa]
        )
        let orangePastry = PairingItem(
            name: "Nagpur Orange Tea Cake & Butter Croissant",
            category: "Café Bakery",
            accentFlavor: .citrus
        )
        rituals.append(BrewRitual(
            title: "Subko-Style Orange Tonic Espresso",
            subtitle: "Double shot of single-origin Indian espresso layered over craft botanical tonic & fresh Nagpur orange",
            method: .espresso,
            level: .intermediate,
            bean: arakuOrganic,
            roast: .medium,
            pairing: orangePastry,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 160,
                ratioText: "1:9",
                targetTimeSeconds: 45,
                temperatureCelsius: 93,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Craft Tonic Foundation", details: "Fill a glass with large clear ice and 120ml Indian botanical craft tonic water.", startSecond: 0, endSecond: 15, isActive: true),
                BrewStep(order: 2, title: "Pull Syrupy Shot", details: "Extract a vibrant 36g double espresso from Araku Valley honey-processed beans.", startSecond: 15, endSecond: 40),
                BrewStep(order: 3, title: "Float & Orange Twist", details: "Pour espresso slowly over the tonic, express fresh Nagpur orange peel oils and drop the wedge in for sparkling effervescence.", startSecond: 40, endSecond: 60)
            ],
            tags: [.seasonal, .competition],
            imageName: "ritual_espresso"
        ))

        // MARK: - 7. Vietnamese-Style Indian Condensed Milk Iced Coffee
        let wayanadPeaberry = CoffeeBean(
            name: "Wayanad High-Grown Peaberry",
            origin: "Wayanad, Kerala, India",
            variety: "Robusta Peaberry Bold",
            process: "Wet Polished",
            altitudeMeters: 950,
            recommendedRoast: .dark,
            notes: [.cocoa, .caramel, .nutty]
        )
        let bakeryRuskPairing = PairingItem(
            name: "Irani Bakery Rusk & Chocolate Brownie",
            category: "Café Bakery Bite",
            accentFlavor: .chocolate
        )
        rituals.append(BrewRitual(
            title: "Vietnamese-Style Indian Iced Coffee",
            subtitle: "Bold South Indian dark roast poured over sweet condensed milk & crushed ice — café energy favourite",
            method: .frenchPress,
            level: .beginner,
            bean: wayanadPeaberry,
            roast: .dark,
            pairing: bakeryRuskPairing,
            metrics: BrewMetrics(
                doseGrams: 22,
                waterMilliliters: 120,
                ratioText: "1:5",
                targetTimeSeconds: 180,
                temperatureCelsius: 95,
                milkTemperatureCelsius: nil,
                grindSize: .mediumFine
            ),
            steps: [
                BrewStep(order: 1, title: "Condensed Milk Bed", details: "Spoon 2 generous tablespoons (35ml) of sweetened condensed milk into the bottom of a heavy glass.", startSecond: 0, endSecond: 20, isActive: true),
                BrewStep(order: 2, title: "Dark Coffee Extraction", details: "Extract 70ml of intensely bold dark roast coffee directly into the glass.", startSecond: 20, endSecond: 140),
                BrewStep(order: 3, title: "Crushed Ice Swirl", details: "Fill glass to the brim with crushed ice and vigorously stir into rich, silky caramel gold.", startSecond: 140, endSecond: 180)
            ],
            tags: [.featured, .beginnerFriendly],
            imageName: "ritual_frenchpress"
        ))

        // MARK: - 8. Araku Valley Tribal Honey-Process Aeropress
        let arakuMicrolot = CoffeeBean(
            name: "Araku Valley Tribal Microlot",
            origin: "Eastern Ghats, India",
            variety: "Red Bourbon & S9",
            process: "Semi-Washed Honey",
            altitudeMeters: 1300,
            recommendedRoast: .light,
            notes: [.berry, .stoneFruit, .caramel]
        )
        let nankhataiPairing = PairingItem(
            name: "Walnut Cardamom Nankhatai",
            category: "Traditional Indian Shortbread",
            accentFlavor: .nutty
        )
        rituals.append(BrewRitual(
            title: "Araku Valley Tribal Aeropress",
            subtitle: "Globally award-winning organic tribal coffee unlocking plum sweetness & honeycomb finish",
            method: .aeropress,
            level: .master,
            bean: arakuMicrolot,
            roast: .light,
            pairing: nankhataiPairing,
            metrics: BrewMetrics(
                doseGrams: 16,
                waterMilliliters: 220,
                ratioText: "1:14",
                targetTimeSeconds: 105,
                temperatureCelsius: 90,
                milkTemperatureCelsius: nil,
                grindSize: .mediumFine
            ),
            steps: [
                BrewStep(order: 1, title: "Inverted Setup & Fill", details: "Invert Aeropress, add 16g Araku grounds, pour 220ml water at 90°C within 20 seconds.", startSecond: 0, endSecond: 20, isActive: true),
                BrewStep(order: 2, title: "Agitate & Steep", details: "Stir 3 times with paddle to unlock wild honey and plum notes, screw on rinsed filter cap, steep until 75s.", startSecond: 20, endSecond: 75),
                BrewStep(order: 3, title: "Flip & Smooth Plunge", details: "Flip onto decanter and press steadily with forearm weight for 30s until soft hiss.", startSecond: 75, endSecond: 105)
            ],
            tags: [.competition, .masterclass],
            imageName: "ritual_aeropress"
        ))

        // MARK: - 9. Shahi Kesar Elaichi Latte
        let mysoreNuggets = CoffeeBean(
            name: "Chikmagalur Mysore Nuggets Extra Bold",
            origin: "Chikmagalur, India",
            variety: "Mysore Nuggets AAA",
            process: "Washed High Grown",
            altitudeMeters: 1400,
            recommendedRoast: .mediumDark,
            notes: [.spice, .caramel, .floral]
        )
        let shahiPairing = PairingItem(
            name: "Almond Rose Nankhatai & Pistachio Shortbread",
            category: "Festive Indian Confection",
            accentFlavor: .floral
        )
        rituals.append(BrewRitual(
            title: "Shahi Kesar Elaichi Latte",
            subtitle: "Festive specialty latte with Kashmiri saffron & crushed cardamom infused in silky steamed milk",
            method: .latte,
            level: .intermediate,
            bean: mysoreNuggets,
            roast: .mediumDark,
            pairing: shahiPairing,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 200,
                ratioText: "1:11",
                targetTimeSeconds: 120,
                temperatureCelsius: 93,
                milkTemperatureCelsius: 65,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Infuse Saffron & Cardamom Milk", details: "Gently warm 180ml whole milk with 4 Kashmiri saffron strands and crushed green cardamom until golden.", startSecond: 0, endSecond: 45, isActive: true),
                BrewStep(order: 2, title: "Extract Espresso", details: "Pull 36g single-origin Chikmagalur espresso into wide cup.", startSecond: 45, endSecond: 75),
                BrewStep(order: 3, title: "Pour Microfoam & Pistachio Dust", details: "Steam spiced milk to silky glossy microfoam, pour latte art, and garnish with roasted slivered pistachios.", startSecond: 75, endSecond: 120)
            ],
            tags: [.seasonal, .morningRitual],
            imageName: "ritual_latte"
        ))

        // MARK: - 10. Bengaluru Filter Cold Coffee
        let bangalorePeaberry = CoffeeBean(
            name: "Bengaluru Peaberry Decoction Blend",
            origin: "Karnataka, India",
            variety: "Peaberry & Chicory",
            process: "Washed & Roasted Chicory",
            altitudeMeters: 1200,
            recommendedRoast: .dark,
            notes: [.caramel, .cocoa, .nutty]
        )
        let chilliCheesePairing = PairingItem(
            name: "Chilli Cheese Toast & Veg Club Sandwich",
            category: "College Café Classic",
            accentFlavor: .spice
        )
        rituals.append(BrewRitual(
            title: "Bengaluru Filter Cold Coffee",
            subtitle: "Thick, frothy, ice-cold blended filter coffee shaken with chilled milk and ice cream",
            method: .latte,
            level: .beginner,
            bean: bangalorePeaberry,
            roast: .dark,
            pairing: chilliCheesePairing,
            metrics: BrewMetrics(
                doseGrams: 20,
                waterMilliliters: 200,
                ratioText: "1:10",
                targetTimeSeconds: 90,
                temperatureCelsius: 85,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Chocolate Drizzle Glass", details: "Swirl rich chocolate syrup inside a tall glass and chill in the freezer.", startSecond: 0, endSecond: 20, isActive: true),
                BrewStep(order: 2, title: "Blend Decoction & Cream", details: "Blend 60ml strong filter coffee decoction, 150ml chilled milk, 1 scoop vanilla ice cream, and 1.5 tbsp sugar for 45s until super frothy.", startSecond: 20, endSecond: 70),
                BrewStep(order: 3, title: "Crown & Dust", details: "Pour into iced glass, crown with the 2-inch thick velvet froth, and dust with fresh coffee grounds.", startSecond: 70, endSecond: 90)
            ],
            tags: [.beginnerFriendly, .featured],
            imageName: "ritual_latte"
        ))

        // MARK: - 11. Malabar Cold Brew Kulfi Float (Desi Affogato)
        let malabarDark = CoffeeBean(
            name: "Monsoon Malabar Dark Roast",
            origin: "Malabar Coast, India",
            variety: "Monsooned Arabica",
            process: "Dry Monsooned",
            altitudeMeters: 1100,
            recommendedRoast: .dark,
            notes: [.cocoa, .nutty, .spice]
        )
        let kulfiFloatPairing = PairingItem(
            name: "Roasted Salted Cashews & Belgian Chocolate Fudge",
            category: "Sweet & Salty Snack",
            accentFlavor: .nutty
        )
        rituals.append(BrewRitual(
            title: "Malabar Cold Brew Kulfi Float",
            subtitle: "Chilled 16-hour Monsoon Malabar cold brew poured over a thick slice of artisanal Malai Kulfi",
            method: .espresso,
            level: .beginner,
            bean: malabarDark,
            roast: .dark,
            pairing: kulfiFloatPairing,
            metrics: BrewMetrics(
                doseGrams: 20,
                waterMilliliters: 100,
                ratioText: "1:5",
                targetTimeSeconds: 60,
                temperatureCelsius: 10,
                milkTemperatureCelsius: nil,
                grindSize: .coarse
            ),
            steps: [
                BrewStep(order: 1, title: "Slice Malai Kulfi", details: "Place a thick disc or scoop of traditional Malai Kulfi into a frozen coupe bowl.", startSecond: 0, endSecond: 20, isActive: true),
                BrewStep(order: 2, title: "Pour Chilled Cold Brew", details: "Slowly pour 100ml bold, 16-hour Monsoon Malabar cold brew concentrate around the kulfi.", startSecond: 20, endSecond: 45),
                BrewStep(order: 3, title: "Spoon Melba", details: "As the condensed milk kulfi melts into the dark coffee, enjoy spoonfuls of rich bittersweet cream.", startSecond: 45, endSecond: 60)
            ],
            tags: [.seasonal, .beginnerFriendly],
            imageName: "ritual_espresso"
        ))

        // MARK: - 12. Wayanad Fine Robusta Espresso Romano
        let wayanadFine = CoffeeBean(
            name: "Wayanad Fine Robusta",
            origin: "Wayanad, Kerala, India",
            variety: "Canephora Fine Robusta",
            process: "Wet Polished",
            altitudeMeters: 950,
            recommendedRoast: .dark,
            notes: [.cocoa, .citrus, .nutty]
        )
        let lemonBiscotti = PairingItem(
            name: "Lemon Ginger Biscotti & Banana Halwa",
            category: "Citrus & Spice Sweet",
            accentFlavor: .citrus
        )
        rituals.append(BrewRitual(
            title: "Wayanad Fine Robusta Espresso Romano",
            subtitle: "High-caffeine Kerala Robusta shot pulled over expressed fresh Indian lemon peel for dense crema",
            method: .espresso,
            level: .intermediate,
            bean: wayanadFine,
            roast: .dark,
            pairing: lemonBiscotti,
            metrics: BrewMetrics(
                doseGrams: 18,
                waterMilliliters: 36,
                ratioText: "1:2",
                targetTimeSeconds: 28,
                temperatureCelsius: 94,
                milkTemperatureCelsius: nil,
                grindSize: .fine
            ),
            steps: [
                BrewStep(order: 1, title: "Express Lemon Peel", details: "Rub fresh Indian lemon peel along the rim of a warm demitasse cup.", startSecond: 0, endSecond: 10, isActive: true),
                BrewStep(order: 2, title: "Extract Thick Crema Shot", details: "Pull 36g high-caffeine Wayanad Robusta directly onto the lemon twist.", startSecond: 10, endSecond: 38),
                BrewStep(order: 3, title: "Electric Crema Sip", details: "Sip immediately for an electric citrus and dark chocolate boost.", startSecond: 38, endSecond: 60)
            ],
            tags: [.morningRitual, .masterclass],
            imageName: "ritual_espresso"
        ))

        // MARK: - 13. Australian Velvet Flat White (Specialty Hot Milk)
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

        // MARK: - 14. Affogato al Caffè Tradizionale
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

        // MARK: - 15. Italian Espresso Shakerato (Authentic Cold)
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

        // MARK: - 16. Japanese V60 Kasuya 4:6 Method
        let sidamaHeirloom = CoffeeBean(
            name: "Sidama Bensa Heirloom",
            origin: "Ethiopia",
            variety: "Indigenous Landraces",
            process: "Washed",
            altitudeMeters: 2150,
            recommendedRoast: .light,
            notes: [.floral, .citrus, .berry]
        )
        let mandarinFinancier = PairingItem(
            name: "Mandarin Orange Almond Financier",
            category: "Brown Butter Pastry",
            accentFlavor: .citrus
        )
        rituals.append(BrewRitual(
            title: "Japanese V60 Kasuya 4:6 Method",
            subtitle: "Award-winning clean black pour-over dialing sweetness & acidity balance",
            method: .v60,
            level: .intermediate,
            bean: sidamaHeirloom,
            roast: .light,
            pairing: mandarinFinancier,
            metrics: BrewMetrics(
                doseGrams: 20,
                waterMilliliters: 300,
                ratioText: "1:15",
                targetTimeSeconds: 210,
                temperatureCelsius: 93,
                milkTemperatureCelsius: nil,
                grindSize: .mediumCoarse
            ),
            steps: [
                BrewStep(order: 1, title: "40% Sweetness Phase (Pours 1 & 2)", details: "Pour 50g water, wait 45s. Pour 70g water (120g total) to govern sweetness balance.", startSecond: 0, endSecond: 90, isActive: true),
                BrewStep(order: 2, title: "60% Strength Phase (Pours 3, 4 & 5)", details: "Divide remaining 180g water into 3 equal 60g pulses every 40 seconds.", startSecond: 90, endSecond: 175),
                BrewStep(order: 3, title: "Drawdown & Swirl", details: "Allow clean drawdown for tea-like jasmine and bergamot clarity.", startSecond: 175, endSecond: 210)
            ],
            tags: [.featured, .masterclass],
            imageName: "ritual_v60"
        ))

        // MARK: - 17. Traditional Turkish Cezve Kahve
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

        // MARK: - 18. Mexican Café de Olla
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

        return rituals
    }

    static func makeAllPairingGuides() -> [CoffeePairingGuide] {
        let chikmagalurPeaberry = CoffeeBean(
            name: "Chikmagalur Peaberry Blend",
            origin: "Karnataka, India",
            variety: "Peaberry & Chicory",
            process: "Washed & Roasted Chicory",
            altitudeMeters: 1250,
            recommendedRoast: .dark,
            notes: [.caramel, .cocoa, .spice]
        )
        let monsoonMalabar = CoffeeBean(
            name: "Monsoon Malabar AA",
            origin: "Karnataka & Kerala, India",
            variety: "S795 & Kent Monsooned",
            process: "Monsooned Natural",
            altitudeMeters: 1100,
            recommendedRoast: .dark,
            notes: [.cocoa, .spice, .nutty]
        )
        let arakuValley = CoffeeBean(
            name: "Araku Valley Tribal Microlot",
            origin: "Eastern Ghats, India",
            variety: "Selection 9 Organic",
            process: "Semi-Washed Honey",
            altitudeMeters: 1300,
            recommendedRoast: .medium,
            notes: [.berry, .stoneFruit, .caramel]
        )
        let coorgDark = CoffeeBean(
            name: "Coorg Estate Dark Roast",
            origin: "Kodagu (Coorg), India",
            variety: "Cauvery & Robusta",
            process: "Shade Grown Natural",
            altitudeMeters: 1100,
            recommendedRoast: .dark,
            notes: [.spice, .cocoa, .nutty]
        )
        let wayanadRobusta = CoffeeBean(
            name: "Wayanad Fine Robusta",
            origin: "Wayanad, Kerala, India",
            variety: "Canephora Fine Robusta",
            process: "Wet Polished",
            altitudeMeters: 950,
            recommendedRoast: .dark,
            notes: [.cocoa, .citrus, .nutty]
        )

        return [
            CoffeePairingGuide(
                bean: chikmagalurPeaberry,
                method: .frenchPress,
                pairings: [
                    PairingItem(name: "Crispy Medu Vada with Coconut Chutney", category: "Traditional Savory", accentFlavor: .caramel),
                    PairingItem(name: "Ghee Mysore Pak", category: "Traditional Sweet", accentFlavor: .caramel)
                ],
                whyItWorks: "Indian Heritage Pairing: The thick, bittersweet chicory-infused decoction is cut cleanly by savory lentil crunch and coconut chutney acidity, while sweet Mysore Pak dissolves into the rich caramel warmth."
            ),
            CoffeePairingGuide(
                bean: monsoonMalabar,
                method: .frenchPress,
                pairings: [
                    PairingItem(name: "Pune Shrewsbury Butter Biscuits", category: "Heritage Bakery Cookie", accentFlavor: .caramel),
                    PairingItem(name: "70% Single-Origin Dark Cacao Bar", category: "Chocolate", accentFlavor: .cocoa)
                ],
                whyItWorks: "Indian Coast Pairing: Naturally low in acidity with dense cedar and earthy spice notes, Monsoon Malabar shines alongside buttery Shrewsbury biscuits and bittersweet dark cocoa."
            ),
            CoffeePairingGuide(
                bean: arakuValley,
                method: .aeropress,
                pairings: [
                    PairingItem(name: "Walnut Cardamom Nankhatai", category: "Indian Shortbread", accentFlavor: .nutty),
                    PairingItem(name: "Almond Dark Chocolate Brownie", category: "Bakery", accentFlavor: .stoneFruit)
                ],
                whyItWorks: "Specialty Tribal Pairing: Clean honey-processed berry and plum brightness balances the rich roasted ghee and nutty crunch of fresh traditional Nankhatai."
            ),
            CoffeePairingGuide(
                bean: coorgDark,
                method: .pourOver,
                pairings: [
                    PairingItem(name: "Warm Buttered Bun Maska", category: "Irani Café Classic", accentFlavor: .caramel),
                    PairingItem(name: "Sesame Peanut Chikki", category: "Crisp Confection", accentFlavor: .spice)
                ],
                whyItWorks: "Comfort Pairing: Bold cocoa bitterness is cushioned by soft bakery bun and melting butter, while caramelized jaggery chikki brings delightful crunchy sweetness."
            ),
            CoffeePairingGuide(
                bean: wayanadRobusta,
                method: .espresso,
                pairings: [
                    PairingItem(name: "Crispy Kerala Banana Chips", category: "Savory Street Bite", accentFlavor: .citrus),
                    PairingItem(name: "Belgian Chocolate Chunk Cookie", category: "Bakery", accentFlavor: .chocolate)
                ],
                whyItWorks: "Intense Punch Pairing: Wayanad's heavy crema and bold cacao profile cuts through crisp coconut oil fried banana chips for an unforgettable sweet-savory contrast."
            )
        ]
    }
}
