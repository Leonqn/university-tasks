window.show_activity = ->
  select = document.querySelector '#select'
  console.log 'qwe'
  r = new XMLHttpRequest()
  r.onreadystatechange = ->
    if r.readyState != 4 or r.status != 200
      return
    document.querySelector('#activity').innerHTML = r.responseText
  r.open 'POST', "/admin", true
  r.setRequestHeader("Content-type","application/x-www-form-urlencoded");
  r.send("ip=#{select.options[select.selectedIndex].value}");
