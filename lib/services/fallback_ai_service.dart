import '../models/enums.dart';
import '../models/event_context.dart';
import '../models/ideas_result.dart';
import 'ai_service.dart';

/// Offline fallback service providing curated, high-quality event ideas and answers.
class FallbackAiService implements AiService {
  @override
  Future<IdeasResult> generateIdeas(EventContext context) async {
    // Artificial small delay to simulate processing
    await Future.delayed(const Duration(milliseconds: 300));

    switch (context.eventType) {
      case EventType.wedding:
        return IdeasResult(
          isFallback: true,
          themeSummary:
              'Royal ${context.themePreference} Celebration in ${context.city} featuring floral mandap, ambient marigold/warm lighting, and traditional welcome notes.',
          decorIdeas: [
            'Entrance arch featuring fresh marigolds, fairy lights, and brass urlis with floating candles.',
            'Warm pastel draping with crystal chandeliers over the main lounge area.',
            'Customized selfie booth featuring a retro rickshaw/floral backdrop.',
            'Table centerpieces with fragrant jasmine and floating tealights.'
          ],
          menuHighlights: [
            'Live Chaat Station (Pani Puri, Aloo Tikki, Sev Puri).',
            if (context.dietaryRequirements.contains('Jain'))
              'Special Jain Buffet: Paneer Pasanda, Dal Makhani (No Onion/Garlic), Kashmiri Pulao.'
            else
              'Royal Main Course: Butter Paneer / Chicken Tikka, Dal Tadka, Garlic Naan.',
            'Dessert Spread: Hot Gulab Jamun with Rabri, Kulfi, and Live Jalebi Counter.'
          ],
          interactiveActivities: [
            'Customized trivia quiz about the couple on digital screens.',
            'Fingerprint tree guestbook canvas where guests leave colorful thumbprints.',
            'Polaroid photo wall where guests clip instant photos with handwritten messages.'
          ],
          entertainmentOptions: [
            'Acoustic live band during dinner cocktail hour.',
            'High-energy DJ with wedding entrance dhol beats for the baraat/dance floor.',
            'Professional emcee to host family game awards and couple dance.'
          ],
          returnGiftIdeas: [
            'Handcrafted scented soy candles in decorative brass jars.',
            'Eco-friendly potted succulents with personalized thank you tags.',
            'Traditional silver-plated bowls filled with premium dry fruits.'
          ],
          sampleDayOfSchedule: [
            '10:00 AM - Vendor arrivals & sound/light setup check.',
            '04:00 PM - Bridal makeup & family photoshoot.',
            '06:30 PM - Guest arrivals & welcome drinks.',
            '07:30 PM - Baraat procession & grand couple entrance.',
            '08:30 PM - Stage ceremony & live buffet dining.',
            '10:30 PM - DJ dance floor & cake cutting.'
          ],
        );

      case EventType.birthday:
        return IdeasResult(
          isFallback: true,
          themeSummary:
              'Vibrant ${context.themePreference} Birthday Extravaganza with interactive games and custom balloon installation.',
          decorIdeas: [
            'Organic balloon arch in pastel gold and ocean blue tones.',
            'Personalized marquee neon sign with age and name.',
            'Dedicated photo nook with themed photo booth props.',
            'LED fairy light backdrop behind cake table.'
          ],
          menuHighlights: [
            'Interactive Mini Burger & Slider station.',
            'Crispy French Fries and Cheesy Nacho Bar.',
            'Customized 2-Tier Theme Fondant Birthday Cake.',
            'Chocolate fountain with fresh fruit skewers and marshmallows.'
          ],
          interactiveActivities: [
            'Musical statues and interactive dance competitions with prizes.',
            'DIY Craft Station: Paint your own ceramic mug or t-shirt.',
            '360-degree video booth experience for guests.'
          ],
          entertainmentOptions: [
            'Magician / Illusionist 30-minute family show.',
            'Professional emcee hosting kids/adult party trivia games.',
            'Upbeat party playlist with wireless karaoke setup.'
          ],
          returnGiftIdeas: [
            'Customized name-printed tote bags or stainless water bottles.',
            'Gourmet cookie and brownie gift boxes.',
            'Mini board games or puzzle sets.'
          ],
          sampleDayOfSchedule: [
            '03:00 PM - Decorator setup and cake delivery.',
            '05:00 PM - Guest arrivals & welcome mocktails.',
            '05:45 PM - Magic show and party games.',
            '06:45 PM - Cake cutting ceremony and singing.',
            '07:15 PM - Dinner buffet open.',
            '08:30 PM - Return gift distribution and farewell.'
          ],
        );

      case EventType.community:
        return IdeasResult(
          isFallback: true,
          themeSummary:
              'Community ${context.themePreference} Meetup in ${context.city} focusing on inclusion, local talent, and seamless logistics.',
          decorIdeas: [
            'Clear directional signage banners and registration counter banner.',
            'Stage backdrop with eco-friendly cloth banner and potted palms.',
            'Comfortable modular seating rows with designated accessibility seats.'
          ],
          menuHighlights: [
            'Buffet lunch / tea counter with samosas, sandwiches, and tea/coffee.',
            'Eco-friendly compostable plates and cutlery.',
            'Hydration station with lemon water and fruit coolers.'
          ],
          interactiveActivities: [
            'Open-mic story sharing session and local talent showcase.',
            'Community feedback idea tree on pinboards.',
            'Raffle draw and recognition awards for top volunteers.'
          ],
          entertainmentOptions: [
            'Local school/community music group performance.',
            'Interactive group drum circle or wellness warmup session.',
            'Keynote address and guest panel discussion.'
          ],
          returnGiftIdeas: [
            'Seed paper bookmarks that sprout flowers when planted.',
            'Re-usable canvas shopping bags with event emblem.',
            'Local artisan handcrafted keychains.'
          ],
          sampleDayOfSchedule: [
            '07:00 AM - Stage & audio equipment setup.',
            '09:00 AM - Registration desk open & welcome tea.',
            '10:00 AM - Opening address & keynote speech.',
            '11:30 AM - Panel discussion & Q&A.',
            '01:00 PM - Community networking lunch.',
            '03:00 PM - Volunteer awards and vote of thanks.'
          ],
        );
    }
  }

  @override
  Future<String> askPlanner(EventContext context, String question) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = question.toLowerCase();

    if (lower.contains('budget') || lower.contains('cost') || lower.contains('money')) {
      return 'For a ${context.eventType.displayName} with ${context.guestCount} guests in ${context.city}, your main cost drivers will be catering per plate and venue rental. We recommend allocating around 35-40% for food and reserving an 8% contingency fund for unexpected extras.';
    } else if (lower.contains('rain') || lower.contains('weather') || lower.contains('outdoor')) {
      return 'When planning an outdoor event, always ensure a waterproof tent/canopy is booked at least 2 weeks in advance and verify that your generator power backup has sufficient KVA rating for sound and lighting.';
    } else if (lower.contains('food') || lower.contains('menu') || lower.contains('cater')) {
      return 'For catering ${context.guestCount} guests, aim for 3-4 appetizers, 2 main courses, 1 live stall (e.g. Chaat or Pasta bar), and 2 desserts. Make sure to confirm dietary preferences like Jain/Vegetarian options beforehand!';
    } else {
      return 'As your event planner, I recommend finalizing your venue and key vendors first. For a ${context.eventType.displayName} on ${context.eventDate.year}-${context.eventDate.month}-${context.eventDate.day}, keep your timeline milestones in mind and reach out to vendors early!';
    }
  }
}
