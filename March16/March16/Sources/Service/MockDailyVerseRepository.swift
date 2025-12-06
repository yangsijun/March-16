//
//  MockDataRepository.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import Foundation

struct MockDailyVerseRepository: DailyVerseRepository {
    static let shared = MockDailyVerseRepository()

    private init() {}
    
    var mockDailyVerses: [DailyVerse] = [
        DailyVerse(id: 1201, month: 12, day: 1, book: "Ecclesiastes", chapter: 12, startVerse: 1, endVerse: 2, content: "Remember now thy Creator in the days of thy youth, while the evil days come not, nor the years draw nigh, when thou shalt say, I have no pleasure in them; While the sun, or the light, or the moon, or the stars, be not darkened, nor the clouds return after the rain:"),
        DailyVerse(id: 1202, month: 12, day: 2, book: "Isaiah", chapter: 12, startVerse: 2, content: "Behold, God is my salvation; I will trust, and not be afraid: for the LORD JEHOVAH is my strength and my song; he also is become my salvation."),
        DailyVerse(id: 1203, month: 12, day: 3, book: "Daniel", chapter: 12, startVerse: 3, content: "And they that be wise shall shine as the brightness of the firmament; and they that turn many to righteousness as the stars for ever and ever."),
        DailyVerse(id: 1204, month: 12, day: 4, book: "1 Corinthians", chapter: 12, startVerse: 4, endVerse: 6, content: "Now there are diversities of gifts, but the same Spirit. And there are differences of administrations, but the same Lord. And there are diversities of operations, but it is the same God which worketh all in all."),
        DailyVerse(id: 1205, month: 12, day: 5, book: "Hosea", chapter: 12, startVerse: 5, content: "Even the LORD God of hosts; the LORD is his memorial."),
        DailyVerse(id: 1206, month: 12, day: 6, book: "Psalms", chapter: 12, startVerse: 6, content: "The words of the LORD are pure words: as silver tried in a furnace of earth, purified seven times."),
        DailyVerse(id: 1207, month: 12, day: 7, book: "Proverbs", chapter: 12, startVerse: 7, content: "The wicked are overthrown, and are not: but the house of the righteous shall stand."),
        DailyVerse(id: 1208, month: 12, day: 8, book: "Ecclesiastes", chapter: 12, startVerse: 8, content: "Vanity of vanities, saith the preacher; all is vanity."),
        DailyVerse(id: 1209, month: 12, day: 9, book: "Romans", chapter: 12, startVerse: 9, content: "Let love be without dissimulation. Abhor that which is evil; cleave to that which is good."),
        DailyVerse(id: 1210, month: 12, day: 10, book: "2 Corinthians", chapter: 12, startVerse: 10, content: "Therefore I take pleasure in infirmities, in reproaches, in necessities, in persecutions, in distresses for Christ’s sake: for when I am weak, then am I strong."),
        DailyVerse(id: 1211, month: 12, day: 11, book: "Hebrews", chapter: 12, startVerse: 11, content: "Now no chastening for the present seemeth to be joyous, but grievous: nevertheless afterward it yieldeth the peaceable fruit of righteousness unto them which are exercised thereby."),
        DailyVerse(id: 1212, month: 12, day: 12, book: "Romans", chapter: 12, startVerse: 12, content: "Rejoicing in hope; patient in tribulation; continuing instant in prayer;"),
        DailyVerse(id: 1213, month: 12, day: 13, book: "Ecclesiastes", chapter: 12, startVerse: 13, content: "Let us hear the conclusion of the whole matter: Fear God, and keep his commandments: for this is the whole duty of man."),
        DailyVerse(id: 1214, month: 12, day: 14, book: "Hebrews", chapter: 12, startVerse: 14, content: "Follow peace with all men, and holiness, without which no man shall see the Lord:"),
        DailyVerse(id: 1215, month: 12, day: 15, book: "Luke", chapter: 12, startVerse: 15, content: "And he said unto them, Take heed, and beware of covetousness: for a man’s life consisteth not in the abundance of the things which he possesseth."),
        DailyVerse(id: 1216, month: 12, day: 16, book: "1 Samuel", chapter: 12, startVerse: 16, content: "Now therefore stand and see this great thing, which the LORD will do before your eyes."),
        DailyVerse(id: 1217, month: 12, day: 17, book: "Romans", chapter: 12, startVerse: 17, endVerse: 18, content: "Recompense to no man evil for evil. Provide things honest in the sight of all men. If it be possible, as much as lieth in you, live peaceably with all men."),
        DailyVerse(id: 1218, month: 12, day: 18, book: "Matthew", chapter: 12, startVerse: 18, content: "Behold my servant, whom I have chosen; my beloved, in whom my soul is well pleased: I will put my spirit upon him, and he shall shew judgment to the Gentiles."),
        DailyVerse(id: 1219, month: 12, day: 19, book: "Proverbs", chapter: 12, startVerse: 19, content: "The lip of truth shall be established for ever: but a lying tongue is but for a moment."),
        DailyVerse(id: 1220, month: 12, day: 20, book: "1 Samuel", chapter: 12, startVerse: 20, content: "And Samuel said unto the people, Fear not: ye have done all this wickedness: yet turn not aside from following the LORD, but serve the LORD with all your heart;"),
        DailyVerse(id: 1221, month: 12, day: 21, book: "Romans", chapter: 12, startVerse: 21, content: "Be not overcome of evil, but overcome evil with good."),
        DailyVerse(id: 1222, month: 12, day: 22, book: "Luke", chapter: 12, startVerse: 22, endVerse: 23, content: "And he said unto his disciples, Therefore I say unto you, Take no thought for your life, what ye shall eat; neither for the body, what ye shall put on. The life is more than meat, and the body is more than raiment."),
        DailyVerse(id: 1223, month: 12, day: 23, book: "1 Samuel", chapter: 12, startVerse: 23, endVerse: 24, content: "Moreover as for me, God forbid that I should sin against the LORD in ceasing to pray for you: but I will teach you the good and the right way: Only fear the LORD, and serve him in truth with all your heart: for consider how great things he hath done for you."),
        DailyVerse(id: 1224, month: 12, day: 24, book: "John", chapter: 12, startVerse: 24, content: "Verily, verily, I say unto you, Except a corn of wheat fall into the ground and die, it abideth alone: but if it die, it bringeth forth much fruit."),
        DailyVerse(id: 1225, month: 12, day: 25, book: "Proverbs", chapter: 12, startVerse: 25, content: "Heaviness in the heart of man maketh it stoop: but a good word maketh it glad."),
        DailyVerse(id: 1226, month: 12, day: 26, book: "1 Corinthians", chapter: 12, startVerse: 26, endVerse: 27, content: "And whether one member suffer, all the members suffer with it; or one member be honoured, all the members rejoice with it. Now ye are the body of Christ, and members in particular."),
        DailyVerse(id: 1227, month: 12, day: 27, book: "Luke", chapter: 12, startVerse: 27, content: "Consider the lilies how they grow: they toil not, they spin not; and yet I say unto you, that Solomon in all his glory was not arrayed like one of these."),
        DailyVerse(id: 1228, month: 12, day: 28, book: "John", chapter: 12, startVerse: 28, content: "Father, glorify thy name. Then came there a voice from heaven, saying, I have both glorified it, and will glorify it again."),
        DailyVerse(id: 1229, month: 12, day: 29, book: "Mark", chapter: 12, startVerse: 29, endVerse: 30, content: "And Jesus answered him, The first of all the commandments is, Hear, O Israel; The Lord our God is one Lord: And thou shalt love the Lord thy God with all thy heart, and with all thy soul, and with all thy mind, and with all thy strength: this is the first commandment."),
        DailyVerse(id: 1230, month: 12, day: 30, book: "Luke", chapter: 12, startVerse: 30, endVerse: 31, content: "For all these things do the nations of the world seek after: and your Father knoweth that ye have need of these things. But rather seek ye the kingdom of God; and all these things shall be added unto you."),
        DailyVerse(id: 1231, month: 12, day: 31, book: "Mark", chapter: 12, startVerse: 31, content: "And the second is like, namely this, Thou shalt love thy neighbour as thyself. There is none other commandment greater than these."),
    ]
    
    func fetchDailyVerse(month: Int, day: Int, versionCode: String) -> DailyVerse? {
        mockDailyVerses.first { $0.month == month && $0.day == day }
    }
}
