$(document).ready(function () {
  var form = new QLrt.FormWidget({ name: "Foo", submitCallback: persist});
  
  var age = new QLrt.SimpleFormElementWidget({
    name: "age", 
    label: "What is your age?",
    valueWidget: new QLrt.IntegerValueWidget() 
  }).appendTo(form);
  
  var y = new QLrt.SimpleFormElementWidget({
    name: "y", 
    label: "Another",
    valueWidget: new QLrt.IntegerValueWidget() 
  }).appendTo(form);
  
  var q79 = new QLrt.ConditionalGroupWidget(new QLrt.LazyValue(
    function () { return [age]; },
    function (age) { return (age > 18); }
  )).appendTo(form);
  
  
  $('#QL-content').append(form.domElement());
  form.activate();
  function persist(data) {
     localStorage['QL-persist'] = JSON.stringify(data);
  }
});