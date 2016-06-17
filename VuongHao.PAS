Program TextVuongHao;
Uses Crt;
Const FI='VuongHao.INP';
      FO='VuongHao.OUT';
Type St100=String;
     St10=String[10];
     TreePtr=^Tree;
     Tree=Record
                Value:Char;
                Right,Left:TreePtr;
          End;
     StackPtr=^StackTree;
     StackTree=Record
                     Ele:TreePtr;
                     Next:StackPtr;
               End;
     TopicPtr=^TopicRecord;
     TopicRecord=Record
                       Info:St100;
                       Next:TopicPtr;
                 End;
     Link=^Node;
     Node=Record
                Key:Char;
                Next:Link;
          End;
     ListR=^ListRRec;
     ListRRec=Record
                    h:Integer;
                    R:St100;
                    Next:ListR;
              End;
     ListMR=^ListMRRec;
     ListMRRec=Record
                     MR:ListR;
                     Next:ListMR;
               End;
Var MR:ListMR;
    Topic:TopicPtr;
    F:Text;
{-------------------------------------------------------------------}
{Cac ham va thu tuc phuc vu chung}
{-------------------------------------------------------------------}
Function Trim(st:String):String;
Var i:Integer;
Begin
     i:=1;
     While (i<=length(st)) do
           Begin
                If (st[i]=' ') Or (st[i]='=') then Delete(st,i,1)
                Else Inc(i);
           End;
     Trim:=st;
End;

Function NegativeChar(c:Char):Char;
Var d:Integer;
Begin
     If c>='a' then d:=-32 else d:=32;
     NegativeChar:=Chr(Ord(c)+d);
End;
{-------------------------------------------------------------------}
{Cac ham va thu tuc phuc vu cho danh sach Topic. Bao gom:
  1. Khoi tao Topic (InitTopic)
  2. Them mot phan tu vao Topic (AddTopic)
  3. Xoa mot phan tu ra khoi Topic (DeleteTopic)}
{-------------------------------------------------------------------}
Procedure InitTopic(Var Topic:TopicPtr);
Begin
     New(Topic);Topic^.Next:=Nil;
End;

Procedure AddTopic(Var First:TopicPtr; st:String);
Var p:TopicPtr;
Begin
     New(p);
     p^.Info:=st;
     p^.Next:=First^.Next;
     First^.Next:=p;
End;

Procedure DeleteTopic(Var First:TopicPtr);
Var p:TopicPtr;
Begin
     p:=First;
     While p<>Nil do
           Begin
                First:=p^.Next;
                Dispose(p);
                If First<>Nil then p:=First^.Next
                Else p:=First;
           End;
End;
{-------------------------------------------------------------------}
{Cac ham phuc vu cho Preprocess. Bao gom:
 1. GoBack
 2. GoForward
 3. Unite}
{-------------------------------------------------------------------}
Function GoBack(i:Integer;st:String):String;
Var Count:Integer;
Begin
     Count:=0;
     Repeat
           Dec(i);
           If st[i]=')' then Inc(Count);
           If st[i]='(' then Dec(Count);
     Until (i=0) Or (Count=0);
     If st[i-1]='!' then Dec(i);
     st:=Copy(st,1,i-1)+'('+Copy(st,i,Length(st));
     GoBack:=st;
End;

Function GoForward(i:Integer;st:String):String;
Var Count:Integer;
Begin
     Count:=0;
     Inc(i);
     If st[i]<>'!' then Dec(i);
     Repeat
           Inc(i);
           If st[i]=')' then Dec(Count);
           If st[i]='(' then Inc(Count);
     Until (i=Length(st)) Or (Count=0);
     st:=Copy(st,1,i)+')'+Copy(st,i+1,Length(st));
     GoForward:=st;
End;

Function Unite(Var i:Integer;st:String):String;
Begin
     st:=GoBack(i,st);
     Inc(i);
     st:=GoForward(i,st);
     Unite:=st;
End;
{-------------------------------------------------------------------}
{Ham phuc vu cho ClearNegative.Bao gom:
 1. Lay phu dinh cua mot bieu thuc (Negative)}
{-------------------------------------------------------------------}
Function Negative(st:String):String;
Var i,j:Integer;
    s:String;
    Function SearchForward(i:Integer;Count:Integer):Integer;
    Begin
         Repeat
               Inc(i);
               If st[i]=')' then Dec(Count);
               If st[i]='(' then Inc(Count);
         Until (i=Length(st)) Or (Count=0);
         SearchForward:=i;
    End;
Begin
     Repeat
           i:=Pos('>',st);
           If i=0 then Break;
           st[i]:='&';
           j:=SearchForward(i,0);
           s:=Negative(Copy(st,i+1,j-i));
           If Pos('>',s)<>0 then s:=Negative(s);
           Delete(st,i+1,j-i);
           Insert(s,st,i+1);
     Until False;
     For i:=1 to Length(st) do
         If (st[i]<>'(') And (st[i]<>')') then
            Case st[i] of
                 '&':st[i]:='|';
                 '|':st[i]:='&';
                Else
                    st[i]:=NegativeChar(st[i]);
            End;
     Negative:=st;
End;
{-------------------------------------------------------------------}
{Cac ham phuc vu cho ham Merger. Bao gom:
 1 Copy
 2 MergerOr
 3 MergerAnd}
{-------------------------------------------------------------------}
Function CopyTree(t:TreePtr):TreePtr;
Var p:TreePtr;
Begin
     If t=Nil then
        CopyTree:=Nil
     Else
         Begin
              New(p);p^.Value:=t^.Value;
              p^.Left:=CopyTree(t^.Left);
              p^.Right:=CopyTree(t^.Right);
              CopyTree:=p;
         End;
End;

Procedure MergerOr(Var t:TreePtr);
     Procedure Merger2And(Var t:TreePtr);
     Var p1,p2,p3,p4:TreePtr;
     Begin
          t^.Value:='&';
          New(p1);p1^.Value:='|';
          p1^.Left:=CopyTree(t^.Left^.Left);
          p1^.Right:=CopyTree(t^.Right^.Left);
          New(p2);p2^.Value:='|';
          p2^.Left:=t^.Left^.Left;
          p2^.Right:=CopyTree(t^.Right^.Right);
          New(p3);p3^.Value:='|';
          p3^.Left:=CopyTree(t^.Left^.Right);
          p3^.Right:=t^.Right^.Left;
          New(p4);p4^.Value:='|';
          p4^.Left:=t^.Left^.Right;
          p4^.Right:=t^.Right^.Right;
          t^.Left^.Left:=p1;
          t^.Left^.Right:=p2;
          t^.Right^.Left:=p3;
          t^.Right^.Right:=p4;
     End;
     {------------------------------------------------}
     Procedure Merger1And(Var t:TreePtr;Var na,a:TreePtr);
     Var p:TreePtr;
     Begin
          t^.Value:='&';
          New(p);p^.Value:='|';
          p^.Right:=a^.Left;
          a^.Value:='|';
          a^.Left:=CopyTree(na);
          If t^.Left=na then
             Begin
                  p^.Left:=t^.Left;
                  t^.Left:=p;
             End
          Else
              Begin
                   p^.Left:=t^.Right;
                   t^.Right:=p;
              End;
     End;
     {-----------------------------------}
     Function HaveAnd(t:TreePtr):Boolean;
     Begin
          If t=Nil then HaveAnd:=False
          Else If t^.Value='&' then HaveAnd:=True
          Else HaveAnd:=HaveAnd(t^.Left) Or HaveAnd(t^.Right)
     End;
     {-----------------------------------}
     Procedure MergerPro(Var t:TreePtr);
     Begin
          MergerOr(t^.Left);
          MergerOr(t^.Right);
          If (t^.Left^.Value='&') And (t^.Right^.Value='&') then Merger2And(t)
          Else If t^.Left^.Value='&' then Merger1And(t,t^.Right,t^.Left)
          Else If t^.Right^.Value='&' then Merger1And(t,t^.Left,t^.Right);
     End;
Begin
     If t<>Nil then
        Begin
             If (t^.Value='|') And (HaveAnd(t)) then MergerPro(t);
             MergerOr(t^.Left);
             MergerOr(t^.Right);
        End;
End;

{Procedure MergerAnd(Var t:TreePtr);
     Procedure Merger2Or(Var t:TreePtr);
     Var p1,p2,p3,p4:TreePtr;
     Begin
          t^.Value:='|';
          New(p1);p1^.Value:='&';
          p1^.Left:=CopyTree(t^.Left^.Left);
          p1^.Right:=CopyTree(t^.Right^.Left);
          New(p2);p2^.Value:='&';
          p2^.Left:=t^.Left^.Left;
          p2^.Right:=CopyTree(t^.Right^.Right);
          New(p3);p3^.Value:='&';
          p3^.Left:=CopyTree(t^.Left^.Right);
          p3^.Right:=t^.Right^.Left;
          New(p4);p4^.Value:='&';
          p4^.Left:=t^.Left^.Right;
          p4^.Right:=t^.Right^.Right;
          t^.Left^.Left:=p1;
          t^.Left^.Right:=p2;
          t^.Right^.Left:=p3;
          t^.Right^.Right:=p4;
     End;
     {------------------------------------------------
     Procedure Merger1Or(Var t:TreePtr;Var no,o:TreePtr);
     Var p:TreePtr;
     Begin
          t^.Value:='|';
          New(p);p^.Value:='&';
          p^.Right:=o^.Left;
          o^.Value:='&';
          o^.Left:=CopyTree(no);
          If t^.Left=no then
             Begin
                  p^.Left:=t^.Left;
                  t^.Left:=p;
             End
          Else
              Begin
                   p^.Left:=t^.Right;
                   t^.Right:=p;
              End;
     End;
     {-------------------------------------
     Function HaveOr(t:TreePtr):Boolean;
     Begin
          If t=Nil then HaveOr:=False
          Else If t^.Value='|' then HaveOr:=True
          Else HaveOr:=HaveOr(t^.Left) Or HaveOr(t^.Right)
     End;
     {-------------------------------------
     Procedure MergerPro(Var t:TreePtr);
     Begin
          MergerAnd(t^.Left);
          MergerAnd(t^.Right);
          If (t^.Left^.Value='|') And (t^.Right^.Value='|') then Merger2Or(t)
          Else If t^.Left^.Value='|' then Merger1Or(t,t^.Right,t^.Left)
          Else If t^.Right^.Value='|' then Merger1Or(t,t^.Left,t^.Right);
     End;
Begin
     If t<>Nil then
        Begin
             If (t^.Value='&') And (HaveOr(t)) then MergerPro(t);
             MergerAnd(t^.Left);
             MergerAnd(t^.Right);
        End;
End;}
{-------------------------------------------------------------------}
{Cac ham va thu tuc phuc vu cho ham Converse. Bao gom:
 1 Them dau ngoac vao bieu thuc
 2 Xoa dau phu dinh
 3 Chuyen ve dang hau to
 4 Xay dung cay bieu thuc
 5 Xoa dau =>
 6 Gom nhom dau |
 7 In ra ket qua sau khi bien doi ve dang chuan (WriteStandard)
 8 Xoa cay}
{-------------------------------------------------------------------}
{1. Them dau ngoac vao bieu thuc}
{-------------------------------------------------------------------}
Procedure Preprocess(Var st:St100);
Var i,j:Integer;
    A:Array[1..3] of Char;
    {---------------------------}
    Procedure InitArray;
    Begin
         A[1]:='&';
         A[2]:='|';
         A[3]:='>';
    End;
Begin
     st:=Trim(st);
     InitArray;
     i:=0;
     j:=1;
     Repeat
           Inc(i);
           If st[i]=A[j] then
              st:=Unite(i,st);
           If i>=Length(st) then
              Begin
                   i:=1;
                   j:=j+1;
              End;
           If j>3 then Break;
     Until False;
End;
{-------------------------------------------------------------------}
{2.Xoa dau phu dinh va dau =>}
{-------------------------------------------------------------------}
Procedure ClearNegative(Var st:St100);
Var i,j,Count:Integer;
    s:St100;
Begin
     Repeat
           i:=Pos('!',st);
           If i=0 then Break;
           Count:=0;
           j:=i;
           Repeat
                 Inc(j);
                 If st[j]='(' then Inc(Count);
                 If st[j]=')' then Dec(Count);
           Until (j=Length(st)) Or (Count=0);
           s:=Copy(st, i+1, j-i);
           If Pos('!', s)>0 then ClearNegative(s);
           s:=Negative(s);
           Delete(st, i, j-i+1);
           Insert(s, st, i);
     Until False;
End;
{---------------------------------------------------------------}
{3. Chuyen bieu thuc ve dang hau to}
{---------------------------------------------------------------}
Procedure Postfix(Var st:St100);
Var i:Integer;
    First:Link;
    s:St100;
    {------------------------------}
    Procedure StackInit;
    Begin
         New(First);First^.Next:=Nil;
    End;
    {-----------------------------------}
    Procedure Push(c:Char);
    Var p:Link;
    Begin
         New(p);p^.Key:=c;
         p^.Next:=First^.Next;
         First^.Next:=p;
    End;
    {-----------------------------------}
    Function StackEmpty:Boolean;
    Begin
         StackEmpty:=(First^.Next=Nil);
    End;
    {-----------------------------------}
    Function Pop:String;
    Var p:Link;
    Begin
         If StackEmpty then Pop:=''
         Else
             Begin
                  Pop:=First^.Next^.Key;
                  p:=First^.Next;
                  First^.Next:=p^.Next;
                  Dispose(p);
             End;
    End;
    {------------------------------------}
Begin
     StackInit;
     i:=1;
     s:='';
     While i<=Length(st) do
           Begin
                Case st[i] of
                     ')':s:=s+Pop;
                     '>':Push(st[i]);
                     '&':Push(st[i]);
                     '|':Push(st[i]);
                     'a'..'z','A'..'Z':Begin
                                            s:=s+st[i];
                                       End;
                End;
                Inc(i);
           End;
     st:=s;
     Dispose(First);
End;
{--------------------------------------------------------------}
{4. Xay dung cay bieu thuc}
{--------------------------------------------------------------}
Function BuildTree(st:St100):TreePtr;
Var i:Integer;
    Top:TreePtr;
    First:StackPtr;
    {-----------------------------}
    Procedure StackInit;
    Begin
         New(First);First^.Next:=Nil;
    End;
    {-----------------------------}
    Procedure Push(e:TreePtr);
    Var p:StackPtr;
    Begin
         New(p);p^.Ele:=e;
         p^.Next:=First^.Next;
         First^.Next:=p;
    End;
    {----------------------------}
    Function Pop:TreePtr;
    Var p:StackPtr;
    Begin
         Pop:=First^.Next^.Ele;
         p:=First^.Next;
         First^.Next:=p^.Next;
    End;
Begin
     StackInit;
     For i:=1 to Length(st) do
           Begin
                Case st[i] of
                     'a'..'z','A'..'Z':Begin
                                            New(Top);
                                            Top^.Value:=st[i];
                                            Top^.Right:=Nil;
                                            Top^.Left:=Nil;
                                       End;
                     '&','|','>':Begin
                                      New(Top);
                                      Top^.Value:=st[i];
                                      Top^.Right:=Pop;
                                      Top^.Left:=Pop;
                                 End;
                End;
                Push(Top);
           End;
     BuildTree:=Pop;
End;
{--------------------------------------------------------------}
{5. Xoa dau => con lai}
{--------------------------------------------------------------}
Procedure ClearInfer(Var t:TreePtr);
     Procedure NegativeInfer(Var t:TreePtr);
     Begin
          If t<>Nil then
             Begin
                  Case t^.Value of
                       '&':t^.Value:='|';
                       '|':t^.Value:='&';
                       'a'..'z','A'..'Z':t^.Value:=NegativeChar(t^.Value);
                  End;
                  NegativeInfer(t^.Right);
                  NegativeInfer(t^.Left);
             End;
     End;
Begin
     If t<>Nil then
        Begin
             If t^.Value='>' then
                Begin
                     t^.Value:='|';
                     ClearInfer(t^.Left);
                     NegativeInfer(t^.Left);
                End
             Else ClearInfer(t^.Left);
             ClearInfer(t^.Right);
        End;
End;
{--------------------------------------------------------------}
{6. Gom nhom dau | hoac dau &}
{--------------------------------------------------------------}
{Procedure Merger(Var t:TreePtr; c:Char);
Begin
     If c='&' then MergerAnd(t)
     Else MergerOr(t);
End;}
{--------------------------------------------------------------}
{7. Chuyen tu cay ve chuoi}
{--------------------------------------------------------------}
Function TreeToString(t:TreePtr):St100;
Begin
     If t=Nil then TreeToString:=''
     Else TreeToString:=TreeToString(t^.Left)+t^.Value+TreeToString(t^.Right);
End;
{--------------------------------------------------------------}
{8. In ra ket qua sau khi bien doi ve dang chuan}
{--------------------------------------------------------------}
Procedure WriteTopicStandard(Topic:TopicPtr);
    Procedure Loop(First:TopicPtr;p:TopicPtr);
    Begin
         If p^.Next=Nil then
            Begin
                  Writeln(F,p^.Info);
            End
         Else
             Begin
                  Loop(First,p^.Next);
                  If p<>First then
                     Begin
                          Writeln(F,p^.Info);
                     End;
             End;
    End;
Begin
     Writeln(F,'Cac bieu thuc sau khi da bien doi:');
     Loop(Topic,Topic);
End;
{--------------------------------------------------------------------}
{8. Ham xoa cay}
{--------------------------------------------------------------------}
Procedure DeleteTree(Var t:TreePtr);
Var p:TreePtr;
Begin
     If t<>Nil then
        Begin
             DeleteTree(t^.Right);
             DeleteTree(t^.Left);
             p:=t;
             t:=Nil;
             Dispose(p);
        End;
End;
{--------------------------------------------------------------------}
{Xu ly danh sach Topic dua ve dang chuan. Thuc hien theo cac buoc sau:
 1. Them dau ngoac vao bieu thuc (Preprocess)
 2. Xoa dau phu dinh (ClearNegative)
 3. Chuyen bieu thuc ve dang hau to (Postfix)
 4. Dua ve cay bieu thuc (BuildTree)
 5. Xoa dau => con lai(ClearInfer)
 6. Gom nhom dau |
    hoac gom nhom dau & voi bieu thuc chung minh (Merger)
 7. Chuyen tu cay ve chuoi (TreeToString)}
{--------------------------------------------------------------------}
Procedure Converse(Var Topic:TopicPtr);
Var p:TopicPtr;
    c:TreePtr;
    A:Array[1..3] of String;
    i:Integer;
Begin
     p:=Topic^.Next;
     Writeln(F,'Ta bien doi cac bieu thuc:');
     While p<>Nil do
           Begin
                A[1]:=p^.Info;
                Preprocess(p^.Info);
                ClearNegative(p^.Info);
                Postfix(p^.Info);
                c:=BuildTree(p^.Info);
                ClearInfer(c);
                A[2]:=TreeToString(c);
                MergerOr(c);
                A[3]:=TreeToString(c);
                p^.Info:=TreeToString(c);
                DeleteTree(c);
                Write(F,A[1]);
                For i:=2 to 3 do
                    If A[i]<>A[i-1] then Write(F,' ð ',A[i]);
                Writeln(F);
                p:=p^.Next;
           End;
     WriteTopicStandard(Topic);
End;
{---------------------------------------------------------------------}
{Lay du lieu tu tap tin dua vao danh sach Topic}
{---------------------------------------------------------------------}
Procedure ReadFile(Var Topic:TopicPtr);
Var FIN:Text;
    i,j:Integer;
    st:St100;
Begin
     Assign(FIN,FI);
     Reset(FIN);
     Writeln(F,'De bai:');
     Writeln(F,'Cho cac dong nhat dung sau:');
     i:=1;
     Readln(FIN,st);
     While st[1]<>'?' do
           Begin
                Writeln(F,i,',',' ',st);
                AddTopic(Topic,st);
                Inc(i);
                Readln(FIN,st);
           End;
     Delete(st,1,1);
     Writeln(F,'Chung minh ',st,'ð1');
     AddTopic(Topic,st);
     Writeln(F,'Bai lam:');
     Close(FIN);
End;
{-------------------------------------------------------------}
{Cac ham va thu tuc phuc vu ham SwitchTo. Bao gom:
 1. InitMR
 2. CleanUp
 3. AddR
 4. AddMR}
{-------------------------------------------------------------}
Procedure InitMR(Var MR:ListMR);
Begin
     New(MR);MR^.Next:=Nil;
End;

Procedure CleanUp(Var st:St100);
Var i:Integer;
    Procedure TheSame(Var st:St100);
    Var i,j:Integer;
    Begin
         i:=1;
         While i<=Length(st) do
               Begin
                    If (st[i] In ['a'..'z']) Or (st[i] In ['A'..'Z']) then
                       Begin
                            j:=i+1;
                            While j<=Length(st) do
                                  Begin
                                       If st[i]=st[j] then Delete(st,j,1);
                                       Inc(j);
                                  End;
                       End;
                    Inc(i);
               End;
    End;
    {--------------------------------}
    Procedure DelOp(Var st:St100);
    Var i:Integer;
    Begin
         i:=1;
         While i<=Length(st) do
               Begin
                    If (st[i]='|') Or (st[i]='&') then Delete(st,i,1);
                    Inc(i);
               End;
    End;
    {--------------------------------}
    Procedure Opposite(Var st:St100);
    Var i,j:Integer;
        Ok:Boolean;
    Begin
         i:=1;
         Ok:=False;
         While i<=Length(st) do
               Begin
                    If (st[i] In ['a'..'z']) Or (st[i] In ['A'..'Z']) then
                       Begin
                            j:=i+1;
                            While j<=Length(st) do
                                  Begin
                                       If NegativeChar(st[i])=st[j] then
                                          Begin
                                               st:='';
                                               Exit;
                                          End;
                                       Inc(j);
                                  End;
                       End;
                    Inc(i);
               End;
    End;
    {----------------------------------}
    Procedure Swap(Var a,b:Char);
    Var t:Char;
    Begin
         t:=a;a:=b;b:=t;
    End;
    {----------------------------------}
    Procedure Sort(Var st:st100);
    Var i,j:Integer;
    Begin
         For i:=1 to Length(st)-1 do
             For j:=i+1 to Length(st) do
                 If st[i]>st[j] then Swap(st[i],st[j]);
    End;
Begin
     TheSame(st);
     i:=Pos('|',st);
     If i<>0 then Opposite(st);
     DelOp(st);
     Sort(st);
End;

Procedure AddR(Var MR:ListMR; st:St100);
Var p:ListR;
    i:Integer;
Begin
     If st<>'' then
        Begin
             New(p);
             p^.R:=st;
             p^.Next:=MR^.MR;
             MR^.MR:=p;
        End;
End;

Procedure AddMR(Var MR:ListMR; st:St100);
Var p:ListMR;
Begin
     New(p);
     p^.MR:=Nil;
     AddR(p,st);
     p^.Next:=MR^.Next;
     MR^.Next:=p;
End;

Function Check(Var MR:ListMR; st:St100):Boolean;
Var p:ListMR;
    q:ListR;
Begin
     Check:=False;
     q:=MR^.Next^.MR;
     While q^.Next<>Nil do
           Begin
                If q^.R=st then
                   Begin
                        Check:=True;
                        Break;
                   End;
                q:=q^.Next;
           End;
End;
{-------------------------------------------------------------}
{Chuyen cac bieu thuc chuan trong Topic sang MR}
{-------------------------------------------------------------}
Procedure SwitchTo(Var MR:ListMR;Var Topic:TopicPtr);
Var p:TopicPtr;
    q:ListMR;
    A:Array[1..10] of St100;
    st:St100;
    i,j:Integer;
Begin
     InitMR(MR);
     p:=Topic^.Next;
     st:=p^.Info;
     j:=0;
     Repeat
           i:=Pos('&',st);
           If i=0 then Break;
           j:=j+1;
           A[j]:=Copy(st,1,i-1);
           Delete(st,1,i);
     Until False;
     j:=j+1;
     A[j]:=st;
     For i:=1 to j do
         Begin
              CleanUp(A[i]);
              AddMR(MR,A[i]);
         End;
     p:=p^.Next;
     While p<>Nil do
           Begin
                st:=p^.Info;
                p:=p^.Next;
                j:=0;
                Repeat
                      i:=Pos('&',st);
                      If i=0 then Break;
                      j:=j+1;
                      A[j]:=Copy(st,1,i-1);
                      Delete(st,1,i);
                Until False;
                j:=j+1;
                A[j]:=st;
                For i:=1 to j do
                    Begin
                         CleanUp(A[i]);
                         If Not Check(MR,A[i]) then
                            Begin
                                 q:=MR^.Next;
                                 While q<>Nil do
                                       Begin
                                            AddR(q,A[i]);
                                            q:=q^.Next;
                                       End;
                            End;
                    End;
           End;
     DeleteTopic(Topic);
End;
{-------------------------------------------------------------}
{Cac ham va thu tuc phuc vu cho VuongHao. Bao gom:
 1. WriteMR
 2. WriteRAnd
 3. WriteR
 4. WriteMR
 5. heuristic
 6. DeleteR
 7. DeleteMR
 8. CheckFinish
 9. CheckNotFinish
 10.SearchMin
 11.SepMR
 12.}
{-------------------------------------------------------------}
Procedure WriteROr(st:St10);
Var i:Integer;
Begin
     Write(F,'(');
     For i:=1 to Length(st) do
          Begin
               Write(F,st[i]);
               If i<>Length(st) then Write(F,'|');
          End;
     Write(F,')');
End;

Procedure WriteRAnd(st:St10);
Var i:Integer;
Begin
     For i:=1 to Length(st) do
         Begin
              Write(F,st[i]);
              If i<>Length(st) then Write(F,'&');
         End;
End;

Procedure WriteR(First:ListR);
Var p:ListR;
Begin
     p:=First;
     While p<>Nil do
           Begin
                If p^.Next=Nil then
                   Begin
                        Write(F,'=>');
                        WriteRAnd(p^.R);
                   End
                Else
                    Begin
                         WriteROR(p^.R);
                         If p^.Next^.Next<>Nil then Write(F,'&');
                    End;
                p:=p^.Next;
           End;
End;

Procedure WriteMR(MR:ListMR);
Var p:ListMR;
    q:ListR;
    st:St10;
Begin
     p:=MR^.Next;
     While p<>Nil do
           Begin
                q:=p^.MR;
                WriteR(q);
                Writeln(F);
                p:=p^.Next;
           End;
End;

Procedure heuristic(Var MR:ListMR);
Var p:ListMR;
    R,A:Set of Char;
    {--------------------------------}
    Procedure InitR;
    Var p:ListR;
        i:Integer;
    Begin
         p:=MR^.MR;
         While p^.Next<>Nil do p:=p^.Next;
         For i:=1 to Length(p^.R) do R:=R+[p^.R[i]];
    End;
    {--------------------------------}
    Procedure InitA;
    Var p:ListR;
    Begin
         p:=MR^.MR;
         While p<>Nil do
               Begin
                    If (Length(p^.R)=1) And (p^.Next<>Nil) then
                       A:=A+[NegativeChar(p^.R[1])];
                    p:=p^.Next;
               End;
    End;
    {--------------------------------}
    Procedure H1;
    Var p:ListR;
    Begin
         p:=MR^.MR;
         While p<>Nil do
               Begin
                    If (p^.Next<>Nil) And (Length(p^.R)=1) then p^.h:=MAXINT
                    Else If p^.Next<>Nil then p^.h:=Length(p^.R)
                    Else p^.h:=0;
                    p:=p^.Next;
               End;
    End;
    {------------------------------}
    Procedure H2;
    Var p:ListR;
        i,j:Integer;
    Begin
         p:=MR^.MR;
         While p<>Nil do
               Begin
                    If (p^.Next<>Nil) And (Length(p^.R)>1) then
                       For i:=1 to Length(p^.R) do
                           If (p^.R[i] In A) Or (p^.R[i] In R) then Dec(p^.h);
                    p:=p^.Next;
               End;
    End;
Begin
     R:=[];
     A:=[];
     InitR;
     InitA;
     H1;
     H2;
End;

Procedure DeleteR(Var R:ListR);
Var p:ListR;
Begin
     p:=R;
     While p<>Nil do
           Begin
                R:=p^.Next;
                Dispose(p);
                p:=R;
           End;
End;

Procedure DeleteMR(Var MR,p:ListMR);
Var q:ListMR;
Begin
     q:=MR;
     While (q^.Next<>Nil) And (q^.Next<>p) do
           q:=q^.Next;
     q^.Next:=p^.Next;
{     DeleteR(p^.MR);
     Dispose(p);}
End;

Function CheckFinish(Var MR,p:ListMR):Boolean;
Var a,b:ListR;
    i:Integer;
    Neg:Char;
Begin
     CheckFinish:=False;
     a:=p^.MR;
     While a^.Next<>Nil do
           Begin
                If Length(a^.R)=1 then
                   Begin
                        Neg:=NegativeChar(a^.R[1]);
                        b:=a^.Next;
                        While b^.Next<>Nil do
                              If (Length(b^.R)<>1) Or (Neg<>b^.R[1]) then b:=b^.Next
                              Else Break;
                        If (Length(b^.R)=1) And (Neg=b^.R[1]) then Break;
                   End;
                a:=a^.Next;
           End;
     If a^.Next<>Nil then
        Begin
             Write(F,'Ta co: ');
             WriteR(p^.MR);
             Writeln(F,' :Co ', a^.R,'ð',b^.R,' o ve trai');
             DeleteMR(MR,p);
             CheckFinish:=True;
        End
     Else
         Begin
              For i:=1 to Length(a^.R) do
                  Begin
                       b:=p^.MR;
                       While b^.Next<>Nil do
                             If (Length(b^.R)<>1) Or (a^.R[i]<>b^.R[1]) then b:=b^.Next
                             Else Break;
                       If (a^.R[i]=b^.R[1]) And (Length(b^.R)=1) then Break;
                  End;
              If (a<>b) then
                 Begin
                      Write(F,'Ta co: ');
                      WriteR(p^.MR);
                      Writeln(F,' :Co ', a^.R[i],'ð',b^.R,' o ve phai');
                      DeleteMR(MR,p);
                      CheckFinish:=True;
                 End;
         End;
End;

Function CheckNotFinish(MR:ListMR; p:ListMR):Boolean;
Var t:ListMR;
    q:ListR;
Begin
     If CheckFinish(MR,p) then CheckNotFinish:=False
     Else
         Begin
              CheckNotFinish:=False;
              t:=MR^.Next;
              While t<>Nil do
                    Begin
                         CheckNotFinish:=True;
                         q:=t^.MR;
                         While q<>Nil do
                               If Length(q^.R)=1 then q:=q^.Next
                               Else If q^.Next<>Nil then
                                    Begin
                                         CheckNotFinish:=False;
                                         Exit;
                                    End
                               Else q:=q^.Next;
                         t:=t^.Next;
                    End;
         End;
End;

Function SearchMin(R:ListR):St10;
Var Min:Integer;
    p:ListR;
    st:St10;
Begin
     Min:=R^.h;
     st:=R^.R;
     p:=R^.Next;
     While p<>Nil do
           Begin
                If (p^.Next<>Nil) And (p^.h<Min) then
                   Begin
                        Min:=p^.h;
                        st:=p^.R;
                   End;
                p:=p^.Next;
           End;
     SearchMin:=st;
End;

Procedure SepMR(Var MR,R:ListMR);
Var i:Integer;
    q:ListMR;
    st:St10;
    First,Last,t,p:ListR;
Begin
     st:=SearchMin(R^.MR);
     For i:=1 to Length(st)-1 do
         Begin
              New(q);
              q^.Next:=R^.Next;
              New(First);New(Last);
              First^.Next:=Nil;
              Last^.Next:=Nil;
              p:=R^.MR;
              While p<>Nil do
                    Begin
                         New(t);
                         t^.R:=p^.R;
                         t^.Next:=Last^.Next;
                         If First^.Next=Nil then First^.Next:=t
                         Else Last^.Next:=t;
                         Last:=t;
                         p:=p^.Next;
                    End;
              q^.MR:=First^.Next;
              R^.Next:=q;
         End;
     q:=R;
     For i:=1 to Length(st) do
         Begin
              p:=q^.MR;
              While (p<>Nil) And (p^.R<>st) do p:=p^.Next;
              p^.R:=Copy(st,i,1);
              q:=q^.Next;
         End;
End;
{-------------------------------------------------------------}
{Thuc hien chung minh bai toan theo phuong phap Vuong Hao}
{-------------------------------------------------------------}
Procedure VuongHao(Var MR:ListMR);
Var p,q,t:ListMR;
Begin
     Repeat
           If MR^.Next=Nil then Break;
           Writeln(F,'Ta phai chung minh:');
           WriteMR(MR);
           p:=MR^.Next;
           While p<>Nil do
                 Begin
                      q:=p^.Next;
                      If CheckNotFinish(MR,p) then
                         Begin
                              Writeln(F,'Ta co:');
                              WriteMR(MR);
                              Writeln(F,'Khong phai la dong nhat dung!');
                              Exit;
                         End;
                      If MR^.Next<>Nil then
                         Begin
                              heuristic(p);
                              SepMR(MR,p);
                         End;
                      p:=q;
                 End;
     Until False;
     Writeln(F,'Chung minh xong!');
End;
{-------------------------------------------------------------}
{Cac buoc thuc hien chuong trinh:
 1.Lay du lieu tu tap tin dua vao Topic (ReadFile)
 2.Xu ly danh sach Topic de dua ve dang chuan (Converse)
 4.Chuyen cac bieu thuc chuan trong danh sach Topic sang MR (SwitchTo)
 3.Chung minh theo phuong phap Vuong Hao (VuongHao)}
{-------------------------------------------------------------}
Begin
     Clrscr;
     Assign(F,FO);
     Rewrite(F);
     InitTopic(Topic);
     ReadFile(Topic);
     Converse(Topic);
     SwitchTo(MR,Topic);
     VuongHao(MR);
     Close(F);
End.