toggle = (->
  t = false
  -> t = !t
)()

setInterval (-> digitalWrite(LED1, toggle())), 1000
setInterval (-> digitalWrite(LED2, toggle())), 2000
setInterval (-> digitalWrite(LED3, toggle())), 3000
