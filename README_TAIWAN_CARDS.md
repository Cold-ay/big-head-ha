# Taiwan Card Catalog

Bank research date: 2026-11-17. EasyCard added: 2026-11-18. Scope: 15 selected credit-card products across 9 banks plus EasyCard, totaling 16 presets across 10 issuing organizations. This is not every Taiwan credit card. Product identity is bundled offline. Rewards, eligibility, rates and promotional percentages are deliberately not hard-coded.

| Issuer | Bundled cards | Official sources |
| --- | --- | --- |
| 悠遊卡公司 | 悠遊卡 EasyCard (stored value, not credit) | [Official ordinary card](https://www.easycard.com.tw/easycard?cls=1515395053&id=1507272299) |
| 國泰世華銀行 | CUBE信用卡; 長榮航空聯名卡 | [CUBE](https://www.cathay-cube.com.tw/cathaybk/personal/product/credit-card/cards/cube), [2026 benefits booklet](https://www.cathaybk.com.tw/cathaybk/-/media/fddd4d9d98754438a663ee9129eb345a.pdf) |
| 中國信託 | LINE Pay信用卡 | [LINE Pay credit card](https://www.ctbcbank.com/web/content/twrbo/zh_tw/cc_index/cc_product/cc_introduction_index/C_LINEPay.html) |
| 玉山銀行 | 玉山Unicard; 玉山U Bear信用卡 | [Unicard](https://www.esunbank.com/zh-tw/personal/credit-card/intro/bank-card/unicard), [U Bear](https://www.esunbank.com/zh-tw/personal/credit-card/intro/bank-card/u-bear) |
| 台新銀行 | 台新Richart卡 | [Richart](https://www.taishinbank.com.tw/TSB/personal/credit/intro/overview/cg047/), [renaming notice](https://www.taishinbank.com.tw/TSB/personal/common/important-notice/TSBankImportantNotice-001508/) |
| 台北富邦銀行 | 富邦J卡; momo聯名卡 | [J card](https://www.fubon.com/banking/JF/), [momo](https://www.fubon.com/banking/personal/credit_card/all_card/momo/momo.htm) |
| 永豐銀行 | DAWHO現金回饋信用卡; 永豐SPORT卡 | [issuer product page](https://bank.sinopac.com/sinopacBT/personal/credit-card/introduction/DAWHO.html) |
| 星展銀行（台灣） | 星展eco永續卡 | [eco](https://www.dbs.com.tw/personal-zh/cards/dbs_eco/index.html) |
| 聯邦銀行 | 聯邦LINE Bank聯名卡; 聯邦吉鶴卡 | [LINE Bank](https://activity.ubot.com.tw/LINEBankCard/index.htm), [issuer selection](https://activity.ubot.com.tw/aws_act/2026/2026threecard_apply/index.htm) |
| 滙豐（台灣） | 滙豐匯鑽卡; 現金回饋御璽卡 | [issuer comparison](https://www.hsbc.com.tw/credit-cards/compare.cashback-signature.cashback-titanium.advance-visa-cashback-credit-card/) |

## Naming And Currency

- Use the current Richart name rather than duplicating renamed @GoGo/FlyGo products. Not all legacy Taishin products are identical; consult the bank's notices for a particular card.
- momo's issuer announced a card-face change starting 2026-07-14. The app uses illustrative issuer styling, not an official or guaranteed current card-face image. [Official notice](https://www.fubon.com/banking/news/creditcard/relate_msg_20260626momo.htm).
- Taiwan products default to TWD when selected in Quick Add. Store the original amount, currency and a user-entered HKD-per-unit rate. HKD remains the common reporting currency; repayment totals are clearly labelled recorded HKD-equivalent spending, not an authoritative TWD statement balance.
- No FX rate is guessed or fetched. Missing/zero rates prevent saving a foreign-currency transaction.
- Require first statement and actual deadline entered by the user. Later dates use that interval as an estimate, not a bank guarantee. Future bank holidays, posting delays, fees and interest are not inferred.
- Monthly recurring rules remain HKD-denominated and are caught up when the app opens/becomes active. They record spending only and do not instruct a bank to charge or pay anything.
- Existing saved product names are retained. Catalog corrections affect new selections and inferred card type, not historical transactions.

## Verification Scope

Regression coverage includes market separation, unique preset IDs, official source metadata, TWD defaults, debit/stored-value exclusion, positive amounts, previous-statement deadlines and manual/paid statement handling. Runtime/UI checks are recorded separately from build success.
