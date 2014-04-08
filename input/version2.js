$(document).ready(function () {
  var form = new QLrt.FormWidget({ name: "Bar", submitCallback: persist});
  
  var age = new QLrt.SimpleFormElementWidget({
    name: "age", 
    label: "Wat is je leeftijd?",
    valueWidget: new QLrt.IntegerValueWidget() 
  }).appendTo(form);
  
  var x = new QLrt.SimpleFormElementWidget({
    name: "x", 
    label: "Another",
    valueWidget: new QLrt.IntegerValueWidget() 
  }).appendTo(form);
  
  var q85 = new QLrt.ConditionalGroupWidget(new QLrt.LazyValue(
    function () { return [age]; },
    function (age) { return (age > 18); }
  )).appendTo(form);
  
  var z = new QLrt.SimpleFormElementWidget({
    name: "z", 
    label: "Yet another",
    valueWidget: new QLrt.IntegerValueWidget() 
  }).appendTo(q85);
  
  $('#QL-content').append(form.domElement());
  form.activate();
  function persist(data) {
     localStorage['QL-persist'] = JSON.stringify(data);
  }
});