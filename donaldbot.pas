{$codepage utf8}

Program Donald;

Uses crt, sysutils;

Const 
  ruta = 'respuestas.txt';
  letras_validas = 'abcdefghijklmnopqrstuvwxyzáéíóúñ';

Type 
  t_archivo = text;
  t_vector = array[1..10] Of string;

Var 
  arch: t_archivo;

Function limpiar_texto(texto: String): String;

Var 
  i, j: Integer;
  palabras, resultado: String;
  v: array Of string;
  palabra_actual: String;
  c: Char;
  es_stopword: Boolean;
Begin
  v := ['de', 'el', 'la', 'los', 'las', 'al', 'del','para','con'];
  texto := LowerCase(texto) + ' ';
  resultado := '';
  palabra_actual := '';

  For i := 1 To Length(texto) Do
    Begin
      c := texto[i];
      If Pos(c, letras_validas) > 0 Then
        palabra_actual := palabra_actual + c
      Else If palabra_actual <> '' Then
             Begin
               es_stopword := False;
               For j := Low(v) To High(v) Do
                 If palabra_actual = v[j] Then
                   Begin
                     es_stopword := True;
                     Break;
                   End;

               If Not es_stopword Then
                 resultado := resultado + palabra_actual + ' ';
               palabra_actual := '';
             End;
    End;

  limpiar_texto := Trim(resultado);
End;

Procedure inicializar_vector(Var v:t_vector);

Var i : integer;
Begin
  For i:=1 To 10 Do
    Begin
      v[i] := '';
    End;
End;
Procedure stringAvector(s:String; Var v:t_vector);

Var i,j: integer;
  auxstring: String;
Begin
  auxstring := '';
  j := 1;
  For i:= 1 To length(s) -1 Do
    Begin
      If (s[i] <> ',') Then
        auxstring := auxstring + s[i]
      Else
        Begin
          v[j] := auxstring;
          inc(j);
          auxstring := '';
        End;
    End;
  auxstring := auxstring + s[i+1];
  v[j] := auxstring;
End;
Function formatear_longitud(texto:String): String;

Var i: byte;
  longlimite : integer;
Begin
  longlimite := 80;
  If length(texto) > longlimite Then
    Begin
      For i:=1 To length(texto) Do
        Begin
          If (i Mod longlimite = 0) And (i < length(texto)) Then
            If (texto[i] <> ' ') Then
              Begin
                Insert('-', texto, i);
                Insert(#13#10 + '        ', texto, i+1)
              End
          Else
            Insert(#13#10 + '        ', texto, i);
          If i = 88 Then longlimite := 88;
        End;
    End;
  formatear_longitud := texto;
End;
Function formatear_usuario(texto:String): String;

Var i: byte;
  longlimite : integer;
Begin
  longlimite := 50;
  If length(texto) > longlimite Then
    Begin
      For i:=1 To length(texto) Do
        Begin
          If (i Mod longlimite = 0) And (i < length(texto)) Then
            If (texto[i] <> ' ') Then
              Begin
                Insert('-', texto, i);
                Insert(#13#10 + '        ', texto, i+1)
              End
          Else
            Insert(#13#10 + '        ', texto, i);
          If i = 58 Then longlimite := 58;
        End;
    End;
  formatear_usuario := texto;
End;
Procedure abrir_archivo();
Begin
  SetTextCodePage(Output, CP_UTF8);
  Assign(arch, ruta);
  If fileExists(ruta) Then
    Begin
      reset(arch);
    End
  Else
    Begin
      rewrite(arch);
    End
End;
Function analizar_entrada(Var entrada:String): string;

Var claves,respuesta,espacio, auxres, auxclave: string;
  arrayclaves: t_vector;
  encontrada: boolean;
  i: integer;
  entrada_formateada: string;
Begin
  abrir_archivo();
  encontrada := false;
  auxres := '';
  auxclave := '';
  entrada_formateada := limpiar_texto(entrada);
  While (Not eof(arch)) Do
    Begin
      readln(arch,claves);
      readln(arch,respuesta);
      readln(arch,espacio);
      inicializar_vector(arrayclaves);
      stringAvector(claves, arrayclaves);
      For i:=low(arrayclaves) To high(arrayclaves) Do
        Begin
          If pos(LowerCase(arrayclaves[i]), entrada_formateada) > 0 Then
            Begin
              //analizar_entrada := respuesta;
              If length(arrayclaves[i]) > length(auxclave) Then
                Begin
                  auxres := respuesta;
                  auxclave := LowerCase(arrayclaves[i]);
                End;
              encontrada := true;
            End;
        End;
    End;
  analizar_entrada := auxres;
  If encontrada= false Then analizar_entrada := 'No he entendido tu mensaje';
End;
Procedure bot_output(Var res:String);
Begin
  textcolor(10);
  write('Donald: ');
  textcolor(15);
  writeln(formatear_longitud(UTF8Decode(analizar_entrada(res))));
End;
Procedure saludo;
Begin
  textcolor(10);
  write('Donald: ');
  textcolor(15);
  writeln(formatear_longitud('Hola! Soy Donald, el bot vegano ¿En qué te puedo ayudar?'));
End;

Function alinear_usuario(texto:String): string;
Begin
  alinear_usuario := (Format('%100s', [texto]));
End;
Procedure LimpiarLinea(posY:integer);
Begin
  // Mueve el cursor al inicio de la línea y borra la línea
  GotoXY(1, posY);
  ClrEol;
End;

Procedure entrada(Var res:String);

Var texto: string;
  posY : integer;
Begin
  write('Usuario: ');
  readln(texto);
  posY :=  whereY -1;
  LimpiarLinea(posY);
  writeln(alinear_usuario(texto));
  res := texto;
End;

Procedure alternar();

Var res: string;
Begin
  Repeat
    entrada(res);
    If res <> 'salir' Then bot_output(res);
  Until  res = 'salir';
End;
Begin
  clrscr;
  saludo;
  alternar();
End.
