import '../models/enums.dart';
import '../models/event_context.dart';
import '../models/vendor_item.dart';

/// Pure Dart deterministic vendor checklist generator tailored to event context.
class VendorService {
  List<VendorItem> generateVendorChecklist(EventContext context) {
    final List<VendorItem> items = [];

    switch (context.eventType) {
      case EventType.wedding:
        items.addAll(_generateWeddingVendors(context));
        break;
      case EventType.birthday:
        items.addAll(_generateBirthdayVendors(context));
        break;
      case EventType.community:
        items.addAll(_generateCommunityVendors(context));
        break;
    }

    // Contextual additions:
    // If outdoor -> add Tent/Canopy & Generator Backup
    if (context.isOutdoor) {
      items.add(const VendorItem(
        id: 'v_outdoor_tent',
        category: 'Infrastructure',
        name: 'Weather Canopy / Tent & AC Cooler',
        priority: PriorityLevel.mustBook,
        leadTime: '3 Months Before',
        questionsToAsk: [
          'Is the canopy waterproof and storm-rated?',
          'Do you provide portable AC / mist fans?',
          'What is the setup and teardown duration?'
        ],
      ));

      items.add(const VendorItem(
        id: 'v_outdoor_gen',
        category: 'Infrastructure',
        name: 'Heavy Duty Sound & Silent Generator Backup',
        priority: PriorityLevel.mustBook,
        leadTime: '2 Months Before',
        questionsToAsk: [
          'What is the total KVA capacity offered?',
          'Is diesel fuel included in the quote?',
          'Is a technician present throughout the event?'
        ],
      ));
    }

    return items;
  }

  List<VendorItem> _generateWeddingVendors(EventContext context) {
    final hasJain = context.dietaryRequirements.contains('Jain') ||
        context.dietaryRequirements.contains('Strict Vegetarian');

    return [
      VendorItem(
        id: 'v_w_venue',
        category: 'Venue & Banquets',
        name: 'Marriage Lawn / Grand Hall',
        priority: PriorityLevel.mustBook,
        leadTime: '9 - 12 Months Before',
        questionsToAsk: const [
          'What is the maximum seating and floating capacity?',
          'Are outside caterers and decorators allowed without royalty fees?',
          'What is the music curfew time enforced by local police?'
        ],
      ),
      VendorItem(
        id: 'v_w_caterer',
        category: 'Catering & Dining',
        name: hasJain
            ? 'Caterer (Jain & Pure Veg Specialist)'
            : 'Master Banquet Caterer',
        priority: PriorityLevel.mustBook,
        leadTime: '6 - 9 Months Before',
        questionsToAsk: [
          'What is the per-plate price for ${context.guestCount} guests?',
          if (hasJain) 'Do you maintain separate kitchen utensils for Jain preparation?',
          'Can we conduct a food tasting session with 4 family members?',
          'Do you handle live counter setups and beverage service?'
        ],
      ),
      const VendorItem(
        id: 'v_w_photo',
        category: 'Media',
        name: 'Wedding Photographer & Drone Crew',
        priority: PriorityLevel.mustBook,
        leadTime: '6 Months Before',
        questionsToAsk: [
          'Does the team include candid, traditional, and cinematic video crews?',
          'What is the delivery timeline for raw files and the finalized album?',
          'Are drone permits included in city limits?'
        ],
      ),
      const VendorItem(
        id: 'v_w_decor',
        category: 'Stage & Ambience',
        name: 'Floral Decorator & Mandap Designer',
        priority: PriorityLevel.recommended,
        leadTime: '4 Months Before',
        questionsToAsk: [
          'Are fresh flowers or artificial silk flowers used for entrance arches?',
          'Is ambient stage LED lighting included in the package?',
          'Can you match our requested color palette?'
        ],
      ),
      const VendorItem(
        id: 'v_w_dj',
        category: 'Entertainment',
        name: 'DJ, Sound System & Dhol Crew',
        priority: PriorityLevel.recommended,
        leadTime: '3 Months Before',
        questionsToAsk: [
          'Will you play custom family song lists for Sangeet / entrance?',
          'Do you supply wireless microphones for speeches?',
          'What is the sound output wattage?'
        ],
      ),
      const VendorItem(
        id: 'v_w_makeup',
        category: 'Styling',
        name: 'Bridal Makeup & Hair Stylist',
        priority: PriorityLevel.recommended,
        leadTime: '3 Months Before',
        questionsToAsk: [
          'Is a paid trial trial session available before booking?',
          'Do you provide saree/lehenga draping assistance?',
          'What brand of products do you use?'
        ],
      ),
      const VendorItem(
        id: 'v_w_invites',
        category: 'Stationery',
        name: 'Invitation Designer & E-Cards',
        priority: PriorityLevel.optional,
        leadTime: '2 Months Before',
        questionsToAsk: [
          'Is an animated WhatsApp e-invite included?',
          'What is the turnaround time for physical box print copies?'
        ],
      ),
    ];
  }

  List<VendorItem> _generateBirthdayVendors(EventContext context) {
    return [
      const VendorItem(
        id: 'v_b_baker',
        category: 'Confectionery',
        name: 'Custom Theme Cake Baker',
        priority: PriorityLevel.mustBook,
        leadTime: '1 Month Before',
        questionsToAsk: [
          'Can you craft a multi-tier fondant cake in our chosen theme?',
          'Do you offer eggless / gluten-free cake flavors?',
          'Is temperature-controlled venue delivery guaranteed?'
        ],
      ),
      const VendorItem(
        id: 'v_b_emcee',
        category: 'Entertainment',
        name: 'Party Host / Game Emcee / Magician',
        priority: PriorityLevel.recommended,
        leadTime: '3 Weeks Before',
        questionsToAsk: [
          'Do you bring your own game props and sound system?',
          'How long is your interactive performance slot?'
        ],
      ),
      const VendorItem(
        id: 'v_b_balloon',
        category: 'Decor',
        name: 'Balloon Arch & Theme Setup Crew',
        priority: PriorityLevel.recommended,
        leadTime: '2 Weeks Before',
        questionsToAsk: [
          'How many hours prior to party start will setup begin?',
          'Do you use bio-degradable helium balloons?'
        ],
      ),
      const VendorItem(
        id: 'v_b_gifts',
        category: 'Favors',
        name: 'Custom Return Gifts Vendor',
        priority: PriorityLevel.optional,
        leadTime: '2 Weeks Before',
        questionsToAsk: [
          'Can you customize gift bags with each child name?',
          'Is there a bulk discount for ${0} units?'
        ],
      ),
    ];
  }

  List<VendorItem> _generateCommunityVendors(EventContext context) {
    return [
      const VendorItem(
        id: 'v_c_audio',
        category: 'Technical',
        name: 'Stage, Audio System & Mic Operator',
        priority: PriorityLevel.mustBook,
        leadTime: '2 Months Before',
        questionsToAsk: [
          'How many lapel and cordless microphones are provided?',
          'Do you supply monitor speakers for stage speakers?',
          'Is a sound technician present on site?'
        ],
      ),
      const VendorItem(
        id: 'v_c_permits',
        category: 'Compliance',
        name: 'Police & Municipal Loudspeaker Permit',
        priority: PriorityLevel.mustBook,
        leadTime: '1 Month Before',
        questionsToAsk: [
          'What documents are needed from the committee?',
          'What is the official decibel limit and time deadline?'
        ],
      ),
      const VendorItem(
        id: 'v_c_volunteer',
        category: 'Operations',
        name: 'Volunteer Coordinator & Badge Supplier',
        priority: PriorityLevel.recommended,
        leadTime: '3 Weeks Before',
        questionsToAsk: [
          'How many volunteers are assigned to crowd management?',
          'Are high-visibility vests or printed badges provided?'
        ],
      ),
    ];
  }
}
