use "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics\data\processed\analyticDataset.dta", clear
teffects ipw ///
  (indmortalityallcause1y) ///
  (exposure ///
   catageatindex sex postcode hbsimd5 indnoturban ///
   inddiabetestype2 indcopd ///
   indrxacei indrxarb indrxaspirin indrxbetablocker indrxclopidogrel indrxdihyccb ///
   indrxloopdiur indrxmincortantag indrxnondihyccb indrxstatin indrxthiazidediur ///
   indrxwarfarin indrxcyp3a4and5 indrxpgp indrxnsaid indrxclariprioryear ///
   indhadechoprioryear lvfunctionimpaired lvhypertrophy lvdilated ladilated mveaabnormal valvediseasemodsev)
   
