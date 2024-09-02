# Happy face
change direction normal esta en 20, 3

- [x] Usar hexadecimal y registro para direcciones ej 128+20, asi solo se modifica relativamente (+4 -2 etc) y no una a una 

---> En x, 128 + algo de 0 a 83
---> En y, 64 + algo de 0 a 5

!!!! NO USAR COUNT 1B ARRUINA EL RELOJ POR ALGUN MOTIVO

00011111 (1F )  move 4 on x and again for eyes 10011000 (24)

get behind first eye on x 2 coor, down one on y 

10010010

01000100


something like this
```
  | |
.____.

00000001 point ULTIMO DIGITO VA A ARRIBA
00000010 
00000100 *5times
00000010 
 00000001 
```
[<img src="carita.png" width="300" />](fig)

