unit UCalendario;

interface
{Teste}

uses
  System.SysUtils, System.Classes, System.Contnrs, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Graphics, System.DateUtils, Vcl.StdCtrls, System.Generics.Collections;

type

  TPosicao = Record
    left: Integer;
    top: Integer;
  End;

  TCalendario = class(TWinControl)
  private
    { Private declarations }
    lista: TComponentList;
    labelAnoMes: TLabel;
    labelNomesDosDias: TLabel;
    FCorUp: TColor;
    FAno: Integer;
    FMes: Integer;
    FCount : Integer;

    posicoes: array [0 .. 41] of TPosicao;

    procedure PanelClick(Sender: TObject);
    procedure SetaCorInicial;
    procedure IniciaLabelAnoMes;
    procedure IniciaLabelNomeDosDias;
    procedure IniciaAnoMes;
    procedure IniciaDias;
    procedure IniciaPosicoes;
    procedure IniciaContador;
    procedure IniciaListaComponentes;
    procedure SetaMes(mes: Integer);
    procedure SetaAno(ano: Integer);
    procedure AtualizaLabelAnoMes;
    procedure AtualizaDiasDoMes;
    procedure SetaTamanhoInicial;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function RetornaDatasSelecionadas: TList<TDateTime>;
    function Count : Integer;

  published
    { Published declarations }
    property corUp: TColor read FCorUp write FCorUp;
    property ano: Integer read FAno write SetaAno;
    property mes: Integer read FMes write SetaMes;
  end;

procedure Register;

const
  QuantidadeDePaineis = 41;
  AlturaComponente = 130;
  LarguraComponente = 144;
  AlturaQuadrante = 15;
  LarguraQuadrante = 20;
  FatorEixoY = 16;
  FatorEixoX = 20;

implementation

procedure Register;
begin
  RegisterComponents('ITGreen', [TCalendario]);
end;

{ TCalendario }

procedure TCalendario.AtualizaDiasDoMes;
var
  i: Integer;
  diasDoMes: Integer;
  diaInicial: Integer;
  ContadorDeDias: Integer;
begin

  for i := 0 to QuantidadeDePaineis do
  begin
    TPanel(lista.Items[i]).Caption := '';
    TPanel(lista.Items[i]).Enabled := False;
  end;

  if (ano > 0) and (mes > 0) then
  begin
    diasDoMes := StrToInt(FormatDatetime('dd', EndOfAMonth(ano, mes)));

    diaInicial := DayOfWeek(StrToDateTime('01/' + InttoStr(mes) + '/' +
      InttoStr(ano))) - 1;

    ContadorDeDias := 0;

    for i := diaInicial to QuantidadeDePaineis do
    begin

      Inc(ContadorDeDias);

      if ContadorDeDias <= diasDoMes then
      begin
        TPanel(lista.Items[i]).Enabled := True;
        TPanel(lista.Items[i]).Caption := InttoStr(ContadorDeDias);
      end;

    end;
  end;

end;

procedure TCalendario.AtualizaLabelAnoMes;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  labelAnoMes.Caption := FormatSettings.LongMonthNames[mes] + '/' + InttoStr(ano);
end;

function TCalendario.Count: Integer;
begin
  Result := FCount;
end;

constructor TCalendario.Create(AOwner: TComponent);
begin
  inherited;
  IniciaContador;
  SetaTamanhoInicial;
  IniciaListaComponentes;
  SetaCorInicial;
  IniciaPosicoes;
  IniciaDias;
  IniciaLabelAnoMes;
  IniciaLabelNomeDosDias;
  IniciaAnoMes;
  IniciaDias;
end;

destructor TCalendario.Destroy;
begin
  lista.Clear;
  lista.Free;
  labelAnoMes.Free;
  inherited;
end;

procedure TCalendario.IniciaAnoMes;
var
  anoAtual, mesAtual, diaAtual: Word;
begin
  DecodeDate(Now, anoAtual, mesAtual, diaAtual);
  ano := anoAtual;
  mes := mesAtual;
end;

procedure TCalendario.IniciaContador;
begin
  FCount := 0;
end;

procedure TCalendario.IniciaDias;
var
  i: Integer;
begin

  for i := 0 to QuantidadeDePaineis do
  begin
    lista.Add(TPanel.Create(Self));
    TPanel(lista.Items[i]).Caption := '';
    TPanel(lista.Items[i]).height := AlturaQuadrante;
    TPanel(lista.Items[i]).left := posicoes[i].left;
    TPanel(lista.Items[i]).tag := 0;
    TPanel(lista.Items[i]).top := posicoes[i].top;
    TPanel(lista.Items[i]).width := LarguraQuadrante;
    TPanel(lista.Items[i]).BevelInner := bvLowered;
    TPanel(lista.Items[i]).ParentBackground := False;
    TPanel(lista.Items[i]).ParentColor := False;
    TPanel(lista.Items[i]).OnClick := PanelClick;
    TPanel(lista.Items[i]).Enabled := False;
    TPanel(lista.Items[i]).Parent := Self;
  end;

end;

procedure TCalendario.IniciaLabelAnoMes;
begin
  labelAnoMes := TLabel.Create(Self);
  labelAnoMes.Caption := '';
  labelAnoMes.left := 0;
  labelAnoMes.top := 0;
  labelAnoMes.Alignment := taCenter;
  labelAnoMes.Align := alTop;
  labelAnoMes.Parent := Self;
end;

procedure TCalendario.IniciaLabelNomeDosDias;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  labelNomesDosDias := TLabel.Create(Self);
  labelNomesDosDias.Caption := FormatSettings.ShortDayNames[1]+' '+
                               FormatSettings.ShortDayNames[2]+' '+
                               FormatSettings.ShortDayNames[3]+' '+
                               FormatSettings.ShortDayNames[4]+' '+
                               FormatSettings.ShortDayNames[5]+' '+
                               FormatSettings.ShortDayNames[6]+' '+
                               FormatSettings.ShortDayNames[7]+' ';
  labelNomesDosDias.left := 0;
  labelNomesDosDias.top := 0;
  labelNomesDosDias.Alignment := taCenter;
  labelNomesDosDias.Align := alTop;
  labelNomesDosDias.Parent := Self;
end;

procedure TCalendario.IniciaListaComponentes;
begin
  lista := TComponentList.Create;
end;

procedure TCalendario.IniciaPosicoes;
var
  i: Integer;

  function DeterminaLinha(posicao: Integer): Integer;
  begin
    case posicao of
      0 .. 6:
        Result := 2;
      7 .. 13:
        Result := 3;
      14 .. 20:
        Result := 4;
      21 .. 27:
        Result := 5;
      28 .. 34:
        Result := 6;
      35 .. 41:
        Result := 7;
    end;
  end;

  function DeterminaColuna(posicao: Integer): Integer;
  begin
    case posicao of
      0, 7, 14, 21, 28, 35:
        Result := 0;
      1, 8, 15, 22, 29, 36:
        Result := 1;
      2, 9, 16, 23, 30, 37:
        Result := 2;
      3, 10, 17, 24, 31, 38:
        Result := 3;
      4, 11, 18, 25, 32, 39:
        Result := 4;
      5, 12, 19, 26, 33, 40:
        Result := 5;
      6, 13, 20, 27, 34, 41:
        Result := 6;
    end;
  end;

begin

  for i := 0 to QuantidadeDePaineis do
  begin
    posicoes[i].left := DeterminaColuna(i) * FatorEixoX;
    posicoes[i].top := DeterminaLinha(i) * FatorEixoY;
  end;

end;

procedure TCalendario.PanelClick(Sender: TObject);
begin

  if TPanel(Sender).BevelInner = bvLowered then
  begin
    TPanel(Sender).BevelInner := bvRaised;
    TPanel(Sender).Color := corUp;
    Inc(FCount);
  end
  else
  begin
    TPanel(Sender).BevelInner := bvLowered;
    TPanel(Sender).Color := clBtnFace;
    Dec(FCount);
  end;

end;

function TCalendario.RetornaDatasSelecionadas: TList<TDateTime>;
var
  resultado: TList<TDateTime>;
  i: Integer;

  function PainelDeDataSelecionado: Boolean;
  begin
    Result := TPanel(lista.Items[i]).BevelInner = bvRaised;
  end;

  procedure AdicionaDataNaLista;
  var
    anoCalendario, mesCalendario, diaCalendario: Word;
  begin

    anoCalendario := ano;
    mesCalendario := mes;
    diaCalendario := StrToInt(TPanel(lista.Items[i]).Caption);

    resultado.Add(EncodeDate(anoCalendario, mesCalendario, diaCalendario));
  end;

begin

  resultado := TList<TDateTime>.Create;

  for i := 0 to QuantidadeDePaineis do
  begin
    if PainelDeDataSelecionado then
    begin
      AdicionaDataNaLista;
    end;
  end;

  Result := resultado;

end;

procedure TCalendario.SetaAno(ano: Integer);
begin
  FAno := ano;
  AtualizaLabelAnoMes;
  AtualizaDiasDoMes;
end;

procedure TCalendario.SetaCorInicial;
begin
  corUp := clHighlight;
end;

procedure TCalendario.SetaMes(mes: Integer);
begin
  FMes := mes;
  AtualizaLabelAnoMes;
  AtualizaDiasDoMes;
end;

procedure TCalendario.SetaTamanhoInicial;
begin
  Self.width := LarguraComponente;
  Self.height := AlturaComponente;
end;

end.
