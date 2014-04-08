$(document).ready(function () {
  var form = new QLrt.FormWidget({ name: "taxOfficeExample", submitCallback: persist});
  
  var hasBoughtHouse = new QLrt.SimpleFormElementWidget({
    name: "hasBoughtHouse", 
    label: "Did you buy a house in 2010?",
    valueWidget: new QLrt.BooleanValueWidget() 
  }).appendTo(form);
  
  var hasMaintLoan = new QLrt.SimpleFormElementWidget({
    name: "hasMaintLoan", 
    label: "Did you enter a loan?",
    valueWidget: new QLrt.BooleanValueWidget() 
  }).appendTo(form);
  
  var q146 = new QLrt.ConditionalGroupWidget(new QLrt.LazyValue(
    function () { return [hasSoldHouse]; },
    function (hasSoldHouse) { return hasSoldHouse; }
  )).appendTo(form);
  
  var sellingPrice = new QLrt.SimpleFormElementWidget({
    name: "sellingPrice", 
    label: "What was the selling price?",
    valueWidget: new QLrt.MoneyValueWidget() 
  }).appendTo(q146);
  var privateDebt = new QLrt.SimpleFormElementWidget({
    name: "privateDebt", 
    label: "Private debts for the sold house:",
    valueWidget: new QLrt.MoneyValueWidget() 
  }).appendTo(q146);
  var valueResidue = new QLrt.SimpleFormElementWidget({
    name: "valueResidue", 
    label: "Value residue:",
    valueWidget: new QLrt.MoneyValueWidget(new QLrt.LazyValue(
    function () { return [sellingPrice, privateDebt]; },
    function (sellingPrice, privateDebt) { return ((sellingPrice - privateDebt) * 0); }
  )) 
  }).appendTo(q146);
  
  var hasSoldHouse = new QLrt.SimpleFormElementWidget({
    name: "hasSoldHouse", 
    label: "Did you sell a house in 2010?",
    valueWidget: new QLrt.BooleanValueWidget() 
  }).appendTo(form);
  
  $('#QL-content').append(form.domElement());
  form.activate();
  function persist(data) {
     localStorage['QL-persist'] = JSON.stringify(data);
  }
});