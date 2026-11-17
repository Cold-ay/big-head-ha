# Card Artwork Catalog

## Bundled Artwork

Updated: 2026-11-18. Twenty original issuer-hosted images are bundled in `CreditCardRecord/CardArt`. The app reads these files locally; browsing cards makes no network requests.

Public-source policy: the original issuer image files are gitignored pending permission review. The manifest and download script are committed, while originals remain in the local workspace. Run `node scripts/fetch-card-art.mjs` to prepare a full development build and artwork tests. Do not redistribute a resulting binary with these files without reviewing issuer permissions. BigHeadHa's original app icon is a separate generated asset included in the repository.

| Issuer | Bundled faces |
| --- | --- |
| HSBC Hong Kong | Red, EveryMile, Visa Signature, Premier Mastercard |
| Citi Hong Kong | Prestige, PremierMiles, Cash Back, Rewards, Rewards UnionPay, Octopus Platinum, HKTVmall, The Club, Plus |
| Hang Seng | Travel+, enJoy |
| DBS Hong Kong | Live Fresh |
| Cathay United Taiwan | CUBE, EVA Air |
| E.SUN Taiwan | Unicard |
| EasyCard | One ordinary EasyCard design; not a credit card or a live stored-value balance |

The [asset manifest](CreditCardRecord/CardArt/manifest.json) records each preset ID, original image URL, official source page and optional normalized display viewport. Original bitmap bytes are retained. The view removes surrounding promotional margins/reflections without stretching or painting over the card design, and preserves portrait cards. Card name, user-entered last four digits and recorded monthly spending appear outside the artwork. Issuer sample names/numbers printed in official artwork are demonstration data, not the user's card details.

Cards without bundled art, including custom cards, use a branded-color fallback with a fine brushed finish. An image represents the named product, not every network, edition or personalized physical-card variant. Catalog availability and benefits are not inferred from image availability.

Some original issuer assets (including CUBE, Citi and DBS Live Fresh) are relatively low resolution; they are not advertised as high-resolution scans or artificially sharpened.

To fetch missing original files during development: `node scripts/fetch-card-art.mjs`. Existing files are left untouched. The script limits source hosts to the issuers in the manifest, requires HTTPS and verifies image signatures and size. It is not part of the app runtime.

### Rights

Artwork and trademarks remain their respective owners' property. Publicly accessible images are **not** assumed to be openly licensed; no redistribution permission has been obtained. Review issuer permissions before distributing a public build. Replace or remove assets where required. Source provenance is recorded to make that review practical.

### UI Evidence

Local simulator screenshots are retained under `artifacts/card-art/` (HSBC Red, portrait Premier, brushed fallback, CUBE, EasyCard and dark/light settings). These captures reproduce issuer artwork, so they are excluded from the public source alongside the original images.

Artwork is non-interactive and exposes one image accessibility element. Oversized source images cannot intercept taps outside their visible viewport; card selection and horizontal swiping remain the surrounding controls' responsibility.

## Earlier Hong Kong Source Index

Research date: 2026-06-19

This catalog maps each researched Hong Kong credit card name to an official issuer page that displays its card face. Where issuers use dynamic pages or changing CDN image paths, the stable product/catalog page is used as the card-face source.

## Bank Issuers

| Issuer | Card name | Card face / official source |
| --- | --- | --- |
| HSBC | HSBC EveryMile Credit Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC Red Credit Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC Visa Signature Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC easy Credit Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC Premier Mastercard | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC Pulse Dual Currency Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC Visa Gold Card for Students | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC Visa Gold Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| HSBC | HSBC UnionPay Dual Currency Card | [HSBC credit cards](https://www.hsbc.com.hk/credit-cards/) |
| Hang Seng Bank | Hang Seng MMPOWER World Mastercard | [Hang Seng cards overview](https://www.hangseng.com/en-hk/personal/cards/overview/) |
| Hang Seng Bank | Hang Seng Travel+ Visa Signature Card | [Hang Seng cards overview](https://www.hangseng.com/en-hk/personal/cards/overview/) |
| Hang Seng Bank | Hang Seng enJoy Visa Platinum Card | [Hang Seng cards overview](https://www.hangseng.com/en-hk/personal/cards/overview/) |
| Standard Chartered Bank HK | Standard Chartered Cathay Mastercard | [Standard Chartered credit cards](https://www.sc.com/hk/credit-cards/) |
| Standard Chartered Bank HK | Standard Chartered Smart Card | [Standard Chartered credit cards](https://www.sc.com/hk/credit-cards/) |
| Standard Chartered Bank HK | Standard Chartered Simply Cash Visa Card | [Standard Chartered credit cards](https://www.sc.com/hk/credit-cards/) |
| Standard Chartered Bank HK | Standard Chartered A.Point Card | [Standard Chartered credit cards](https://www.sc.com/hk/credit-cards/) |
| Citibank Hong Kong | Citi Prestige Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi PremierMiles Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi Cash Back Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi Rewards Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi Rewards UnionPay Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi Plus Credit Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi Octopus Platinum Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi HKTVmall Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Citibank Hong Kong | Citi The Club Credit Card | [Citi credit cards](https://www.citibank.com.hk/english/credit-cards/) |
| Bank of China (Hong Kong) | BOC Bliss Card | [BOC credit card product listing](https://www.bochk.com/dam/boccreditcard/cardproductlisting/eng/index.html) |
| Bank of China (Hong Kong) | BOC Cheers Card | [BOC credit card product listing](https://www.bochk.com/dam/boccreditcard/cardproductlisting/eng/index.html) |
| Bank of China (Hong Kong) | BOC Chill Card | [BOC credit card product listing](https://www.bochk.com/dam/boccreditcard/cardproductlisting/eng/index.html) |
| DBS Bank Hong Kong | DBS Black World Mastercard | [DBS credit cards](https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page) |
| DBS Bank Hong Kong | DBS Eminent Card | [DBS credit cards](https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page) |
| DBS Bank Hong Kong | DBS COMPASS VISA | [DBS credit cards](https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page) |
| DBS Bank Hong Kong | DBS Live Fresh Card | [DBS credit cards](https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page) |
| DBS Bank Hong Kong | DBS Black American Express Card | [DBS credit cards](https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page) |
| DBS Bank Hong Kong | DBS VISA Business Card | [DBS credit cards](https://www.dbs.com.hk/personal/credit-cards/credit-cards/default.page) |

## Non-Bank / Specialist Issuers

| Issuer | Card name | Card face / official source |
| --- | --- | --- |
| PrimeCredit | EarnMORE Credit Card | [PrimeCredit credit cards](https://www.primecredit.com/credit-card/) |
| PrimeCredit | EarnMORE UnionPay Credit Card | [EarnMORE Credit Card](https://www.primecredit.com/credit-card/earnmore/) |
| PrimeCredit | WeWa Credit Card | [PrimeCredit credit cards](https://www.primecredit.com/credit-card/) |
| PrimeCredit | WeWa Visa Signature Credit Card | [WeWa Credit Card](https://www.wewacard.com/) |
| AEON Credit Service (Asia) | AEON UnionPay Credit Card | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON Visa Credit Card | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON JCB Credit Card | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON CARD WAKUWAKU | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON Mastercard Credit Card | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON Card JAL | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON Card Premium Visa | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON Card Premium Mastercard | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | AEON Card Premium UnionPay | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | Watami Visa Card | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | DR-MAX Titanium Mastercard | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | SPCA Mastercard - Puppy | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| AEON Credit Service (Asia) | SPCA Mastercard - Kitten | [AEON card types](https://www.aeon.com.hk/tc/credit-card/card-type.html) |
| American Express Hong Kong | The Platinum Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Explorer Credit Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Platinum Credit Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | Blue Cash Credit Card from American Express | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Essential Credit Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Gold Credit Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Credit Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Peninsula Platinum Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Peninsula Gold Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Gold Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Corporate Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Gold Corporate Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Gold Business Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Business Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Classic Corporate Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
| American Express Hong Kong | American Express Elite Corporate Card | [American Express all cards](https://www.americanexpress.com/hk/en/credit-cards/all-cards/) |
