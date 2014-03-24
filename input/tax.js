$(document).ready(function () {
  var form = new QLrt.FormWidget({ name: "taxOfficeExample", submitCallback: persist});
  
  var hasSoldHouse = new QLrt.SimpleFormElementWidget({
    name: "hasSoldHouse", 
    label: "Did you sell a house in 2010?",
    valueWidget: new QLrt.BooleanValueWidget() 
  }).appendTo(form);
  
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
  
  var q205 = new QLrt.ConditionalGroupWidget(new QLrt.LazyValue(
    function () { return [hasSoldHouse]; },
    function (hasSoldHouse) { return hasSoldHouse; }
  )).appendTo(form);
  
  var sellingPrice = new QLrt.SimpleFormElementWidget({
    name: "sellingPrice", 
    label: "What was the selling price?",
    valueWidget: new QLrt.MoneyValueWidget() 
  }).appendTo(q205);
  var privateDebt = new QLrt.SimpleFormElementWidget({
    name: "privateDebt", 
    label: "Private debts for the sold house:",
    valueWidget: new QLrt.MoneyValueWidget() 
  }).appendTo(q205);
  var valueResidue = new QLrt.SimpleFormElementWidget({
    name: "valueResidue", 
    label: "Value residue:",
    valueWidget: new QLrt.MoneyValueWidget(new QLrt.LazyValue(
    function () { return [privateDebt, sellingPrice]; },
    function (privateDebt, sellingPrice) { return (sellingPrice - privateDebt); }
  )) 
  }).appendTo(q205);
  
  $('#QL-content').append(form.domElement());
  form.activate();
  function persist(data) {
     localStorage['QL-persist'] = JSON.stringify(data);
  }
});