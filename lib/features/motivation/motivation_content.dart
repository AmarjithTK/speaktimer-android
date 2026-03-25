// ============================================================================
// MotivationContent - Centralized motivational quotes by category
// ============================================================================
//
// This feature module encapsulates all motivational content used to inspire
// and encourage users during breaks and focus sessions.
//
// Structure:
// - motivationCategories: List of available quote categories (7 total)
// - quotesByCategory: Map of categories to quote lists
//
// Content Organization:
// 1. General - Universal productivity tips for all languages/cultures
// 2. General Malayalam - Malayalam-specific wellness & productivity advice
// 3. Focus - Maintaining concentration during work sessions
// 4. Discipline - Building habits and consistency
// 5. Calm - Mindfulness and stress reduction
// 6. Positivity - Encouragement and self-affirmation
// 7. Historic Figures - Inspiring quotes from notable people
//
// Usage:
// - Load via QuoteRotationService.nextQuoteFromMap(category)
// - Default category is 'General' (always available)
// - Falls back to 'General' if user-selected category not found
//
// Future Enhancement:
// - [ ] Externalize quotes to asset files (JSON)
// - [ ] Load from database for easy updates without app rebuild
// - [ ] User-submitted quotes feature
// - [ ] Spaced repetition: prefer less-recently-used quotes
//
// Localization Strategy:
// - English quotes in 'General' category
// - Malayalam content in dedicated 'General Malayalam' category
// - Quotes remain const (compile-time safe, no runtime overhead)

const List<String> motivationCategories = [
  'General',
  'General Malayalam',
  'Focus',
  'Discipline',
  'Calm',
  'Positivity',
  'Historic Figures',
];

const Map<String, List<String>> quotesByCategory = {
  'General': [
    "Use this moment well — it won't come back.",
    "Small steps every hour build the life you want.",
    "Time is the only resource you cannot earn back.",
    "Progress, not perfection, is what time rewards.",
    "Your work right now is compounding silently.",
  ],
  'General Malayalam': [
    "വലിയ ടാസ്ക് ചെറു ഘട്ടങ്ങളാക്കി തുടങ്ങിയാൽ ഭയം കുറയും.",
    "ഒരു സമയം ഒരു ജോലി മാത്രം; ഗുണമേന്മ സ്വയം ഉയരും.",
    "ചങ്ക് അടിസ്ഥാനത്തിൽ ജോലി ചെയ്താൽ ബേൺഔട്ട് കുറയും.",
    "സ്ട്രെസ് ഉയർന്നാൽ 10 ആഴത്തിലുള്ള ശ്വസനം ചെയ്യൂ, പിന്നെ തുടരു.",
    "കണ്ണുകൾ സ്ക്രീനിൽ നിന്നും മാറ്റി ദൂരേക്ക് നോക്കുന്നത് കണ്ണ് സമ്മർദ്ദം കുറക്കും.",
    "എഴുന്നേറ്റ് നീങ്ങുന്നത് ഉൽപാദനക്ഷമത കുറയ്ക്കില്ല; അത് ദീർഘകാലം നിലനിർക്കും.",
    "ശരീരത്തെ സംരക്ഷിക്കുന്നത് സമയത്തെ സംരക്ഷിക്കുന്നതുപോലെയാണ്.",
    "നല്ല ഭക്ഷണം, മതിയായ വെള്ളം, ചെറിയ വ്യായാമം — സ്ഥിരമായ വിജയം ഇതിൽ നിന്നാണ്.",
    "ഇന്ന് ചെയ്തൊരു ചെറിയ ഹെൽത്തി തീരുമാനം നാളെ വലിയ ലാഭമാകും.",
    "ഇടവേളകളില്ലാത്ത ജോലി വേഗം ക്ഷീണത്തിലേക്ക് നയിക്കും.",
    "ശ്രദ്ധിച്ചു ഭക്ഷണം കഴിക്കൂ; വേഗത്തിൽ കഴിക്കുന്നത് അധികഭക്ഷണത്തിലേക്ക് നയിക്കും.",
    "തുടർച്ചയായി ഇരിക്കരുത്; 45 മിനിറ്റ് കഴിഞ്ഞാൽ നിർബന്ധമായി എഴുന്നേൽക്കൂ.",
    "നിന്റെ ആരോഗ്യമാണ് നിന്റെ ഏറ്റവും വലിയ പ്രോജക്റ്റ് — ദിവസേന അതിൽ നിക്ഷേപിക്കൂ.",
    "സ്മാർട്ട് ആയി ജോലി ചെയ്യൂ: പ്ലാൻ, ചങ്കുകൾ, ബ്രേക്കുകൾ, സ്ഥിരത.",
    "ശരീരവും മനസും ഒത്തൊരുമിച്ചാൽ മാത്രമേ ദീർഘകാല ഫലം ലഭിക്കൂ.",
    "ഇപ്പോൾ ഒരു ചെറിയ നടപ്പ് എടുക്കൂ; പിന്നത്തെ മണിക്കൂർ കൂടുതൽ ഫോകസ് ആയിരിക്കും.",
    "നല്ല ജീവിതം ഒരുദിവസം കൊണ്ട് വരില്ല; നല്ല ശീലങ്ങൾ ദിനംപ്രതി കൂട്ടിച്ചേർന്നതാണ്.",
    "ഇപ്പോൾ ഉള്ള നിമിഷം ശരിയായി ഉപയോഗിക്കൂ; അത് തിരിച്ചുവരില്ല.",
    "ചെറിയ തുടക്കങ്ങൾ തന്നെയാണ് വലിയ മാറ്റങ്ങൾ ഉണ്ടാക്കുന്നത്.",
    "ഒരു മണിക്കൂറിൽ 5 മിനിറ്റ് ശരീരം നീക്കുന്നത് ആരോഗ്യ നിക്ഷേപമാണ്.",
    "നീണ്ട സമയം ഇരിക്കാതെ ഇടയ്ക്കിടെ എഴുന്നേറ്റ് നടക്കൂ.",
    "25 മിനിറ്റ് ജോലി, 5 മിനിറ്റ് ബ്രേക്ക് — ശ്രദ്ധയും ശരീരവും രക്ഷിക്കും.",
    "ഓരോ ബ്രേക്കിലും തോളുകൾ നേരെയാക്കി ആഴത്തിൽ ശ്വസിക്കൂ.",
    "വർക്ക്ഔട്ട് ഒരു ഓപ്ഷൻ അല്ല, ശരീരത്തിന് വേണ്ട അടിസ്ഥാന പരിചരണമാണ്.",
    "ഭക്ഷണം സമയം പാലിച്ച് കഴിക്കുന്നത് ഉത്സാഹം സ്ഥിരമാക്കും.",
    "പ്ലേറ്റിൽ പകുതി പച്ചക്കറി, കാൽഭാഗം പ്രോട്ടീൻ, കാൽഭാഗം കാർബ്സ്.",
    "തീരെ വിശന്ന ശേഷം ഭക്ഷണം കഴിക്കരുത്; പ്ലാൻ ചെയ്താൽ നിയന്ത്രണം കൂടും.",
    "വെള്ളം കുടിക്കുന്നത് മറക്കരുത്; ദേഹദാഹം ക്ഷീണം പോലെ തോന്നിക്കും.",
    "മന്ദഗതിയിൽ ചവച്ച് കഴിക്കൂ; ജീർണ്ണവും തൃപ്തിയും മെച്ചപ്പെടും.",
    "ജങ്ക് ഫുഡ് കുറച്ചാൽ നാളത്തെ ഊർജം കൂടും.",
    "ഓരോ മണിക്കൂറിലും ഒരു മിനിറ്റ് നീട്ടി നിൽക്കൂ; പിന്‍വേദന കുറയും.",
    "കസേരയിൽ കുടുങ്ങി ഇരിക്കാതെ, ചെറിയ വാക്കിംഗ് ബ്രേക്കുകൾ ഇടൂ.",
    "ശരിയായ ഉറക്കം ഇല്ലെങ്കിൽ മികച്ച ജോലി പോലും ക്ഷീണമായി തോന്നും.",
    "ദിവസം 20-30 മിനിറ്റ് നടക്കുന്നത് മനസിനും ശരീരത്തിനും മരുന്നാണ്.",
    "പ്രതിദിനം ഒരേ സമയം എഴുന്നേൽക്കുന്നത് ശീലശക്തി വളർത്തും.",
  ],
  'Focus': [
    'Your attention is your most valuable currency.',
    'An hour of deep work is worth a day of distraction.',
    'One focused hour can change a whole day.',
    'Clarity comes to those who use their time with intention.',
    'Focused effort now creates freedom later.',
  ],
  'Discipline': [
    'Discipline is choosing what you want most over what you want now.',
    'Greatness is built minute by minute.',
    'The best time to start was yesterday. The second best is now.',
    'Consistency over time is unstoppable.',
    'Stay the course. The results are coming.',
  ],
  'Calm': [
    'Be present. This hour is a gift.',
    'Breathe, focus, and make this moment count.',
    'Each hour is a fresh canvas. Paint it well.',
    'You have enough time for what truly matters.',
    'Let this hour be better than the last.',
  ],
  'Positivity': [
    'What you do right now shapes who you become.',
    'Your future self will thank you for the work you do now.',
    'Do something today that your future self will be proud of.',
    'Momentum is built one intentional moment at a time.',
    "A year from now you'll wish you had started today.",
  ],
  'Historic Figures': [
    'Aristotle said: We are what we repeatedly do. Excellence, then, is a habit.',
    'Leonardo da Vinci said: Time stays long enough for anyone who will use it.',
    'Benjamin Franklin said: Lost time is never found again.',
    'Maya Angelou said: Nothing will work unless you do.',
    'Bruce Lee said: The successful warrior is the average person, with laser-like focus.',
  ],
};
