// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// The following code is from CruiseControl.rb
// A shameless copy of their code.
function toggle_section(section) {
  if (section.className == "section_open")
    section.className = "section_closed"
  else
    section.className = "section_open"
}

// fade flashes automatically 
Event.observe(window, 'load', function() { 
  $A(document.getElementsByClassName('error')).each(function(o) {
    o.opacity = 100.0
    Effect.Fade(o, {duration: 5.0})
  });
});