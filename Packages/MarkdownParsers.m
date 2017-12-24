(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



MarkdownToXML::usage=
	"Converts markdown to XML";


Begin["`Private`"];


markdownToXMLFormat//ClearAll


(* ::Subsubsection::Closed:: *)
(*Meta*)



markdownToXMLFormat["Meta",text_]:=
	XMLElement["meta",
		Normal@AssociationThread[
			{"name","content"},
			StringTrim@
				StringSplit[#,":",2]
			],
		{}
		]&/@StringSplit[text,"\n"];


(* ::Subsubsection::Closed:: *)
(*FenceBlock*)



markdownToXMLFormat[
	"FenceBlock",
	text_
	]:=
	With[{
		striptext=
			StringSplit[
				StringTrim[
					text,
					StringRepeat["`",
						StringLength@text-
							StringLength@StringTrim[text,StartOfString~~("`"..)]
						]
					],
				"\n",
				2
				]
		},
		XMLElement["pre",
			{},
			{
				XMLElement["code",
					If[!StringMatchQ[First@striptext,Whitespace],
						{"class"->"language-"<>StringTrim[First@striptext]},
						{}
						],
					{
						"\n"<>Last@striptext
						}
					]
				}
			]
		]


(* ::Subsubsection::Closed:: *)
(*CodeBlock*)



markdownToXMLFormat[
	"CodeBlock",
	text_
	]:=
	With[{
		stripableWhitespace=
			First@
				MinimalBy[
					StringCases[text,
						StartOfLine~~w:Whitespace?(StringFreeQ["\n"])~~
							Except[WhitespaceCharacter]:>w
						],
					StringLength
					]
		},
		XMLElement["pre",
			{},
			{
				XMLElement["code",
					{},
					{
						StringTrim@
							StringReplace[
								text,
								StartOfLine~~stripableWhitespace->""
								]
						}
					]
				}
			]
		]


(* ::Subsubsection::Closed:: *)
(*QuoteBlock*)



markdownToXMLFormat[
	"QuoteBlock",
	text_
	]:=
	With[{
		quoteStripped=
			StringReplace[
				text,
				StartOfLine~~">"->""
				]
		},
		XMLElement["blockquote",
			{},
			markdownToXML[quoteStripped]
			]
		]


(* ::Subsubsection::Closed:: *)
(*Header*)



markdownToXMLFormat[
	"Header",
	text_
	]:=
	With[{t=StringTrim[text]},
		XMLElement[
			"h"<>
				ToString[StringLength[t]-
					StringLength[StringTrim[t,StartOfString~~"#"..]]],
			{},
			markdownToXML[StringTrim[t,StartOfString~~"#"..],$markdownToXMLElementRules]
			]
		]


(* ::Subsubsection::Closed:: *)
(*Item*)



markdownToXMLItemRecursiveFormat[l_]:=
	With[
		{
			number=l[[1,1,2]]
			},
		XMLElement[
			Switch[l[[1,1,1]],
				DigitCharacter,
					"ol",
				_,
					"ul"
				],
			{},
			Flatten@Replace[
				SplitBy[l,
					#[[1,2]]==number&
					],
				{
					mainlist:
						{
								{_, number}->_,
								___
								}:>
							Last/@mainlist,
					sublist_:>
						markdownToXMLItemRecursiveFormat[sublist]
					},
				1
				]
			]
		]


markdownToXMLFormat["Item",text_String]:=
	With[{
		lines=
			StringJoin/@
				Partition[
					StringSplit[text,
						StartOfLine~~
							ws:(Whitespace|"")~~
								thing:("* "|"- "|((DigitCharacter..~~"."))):>
							ws<>thing
						],
					2
					]
		},
		markdownToXMLItemRecursiveFormat/@
			SplitBy[
				With[{
					subtype=
						Floor[
							(StringLength[#]
								-StringLength@StringTrim[#, StartOfString~~Whitespace])/2
							],
					thingtype=
						Replace[
							StringTake[
								StringTrim[#,StartOfString~~Whitespace],
								2],{
							t:("* "|"- "):>t,
							_->DigitCharacter
							}]
					},
					{thingtype,subtype}->
						XMLElement["li",{},
							markdownToXML@
								StringTrim[
									StringTrim[#,
										(Whitespace|"")~~
											("* "|"- "|((DigitCharacter..~~". ")))
										]
									]
							]
					]&/@lines,
			#[[1,1]]&
			]
	]


(* ::Subsubsection::Closed:: *)
(*ItalBold*)



markdownToXMLFormat[
	"ItalBold",
	t_
	]:=
	With[
		{
			new=
				StringTrim[t, Repeated["*"|"_"]]
			},
		Which[
			StringLength[t]-StringLength[new]<4,
				XMLElement["em", {}, 
					markdownToXML[new,
						$markdownToXMLElementRules
						]
					],
			StringLength[t]-StringLength[new]<6,
				XMLElement["strong", {}, 
					markdownToXML[new,
						$markdownToXMLElementRules
						]
					],
			True,
				XMLElement["em", {},
					{
						XMLElement["strong", {}, 
							markdownToXML[new,
								$markdownToXMLElementRules
								]
							]
						}
					]
			]
		]


(* ::Subsubsection::Closed:: *)
(*Delimiter*)



markdownToXMLFormat[
	"Delimiter",
	_
	]:=
	XMLElement["hr",{},{}]


(* ::Subsubsection::Closed:: *)
(*CodeLine*)



markdownToXMLFormat[
	"CodeLine",
	text_
	]:=
	With[{
		striptext=
			StringTrim[
				text,
				StringRepeat["`",
					StringLength@text-
						StringLength@StringTrim[text,StartOfString~~("`"..)]
					]
				]
		},
		XMLElement["code",{},{striptext}]
		]


(* ::Subsubsection::Closed:: *)
(*XMLLine*)



markdownToXMLFormat[
	"XMLBlock"|"XMLLine",
	text_
	]:=
	FirstCase[
		ImportString[text,{"HTML","XMLObject"}],
		XMLElement["body"|"head",_,b_]:>b,
		"",
		\[Infinity]
		]


(* ::Subsubsection::Closed:: *)
(*Hyperlink*)



markdownToXMLFormat[
	"Link",
	text_
	]:=
	With[{
		bits=
			{StringRiffle[#[[;;-2]], "]("], #[[-1]]}&@StringSplit[
				text,
				"]("
				]
		},
		XMLElement["a",
			{
				"href"->
					StringTrim[Last[bits],")"]
				},
			markdownToXML[
				StringTrim[First[bits],"["],
				$markdownToXMLElementRules
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*Img*)



markdownToXMLFormat[
	"Image",
	text_
	]:=
	With[{
		bits=
			{StringJoin@#[[;;-2]], #[[-1]]}&@StringSplit[
				text,
				"]("
				]
		},
		XMLElement["img",
			{
				"src"->
					StringTrim[Last[bits],")"],
				"alt"->
					StringTrim[First[bits],"!["]
				},
			{}
			]
		]


markdownToXMLFormat[
	"ImageRef",
	text_
	]:=
	With[{
		bits=
			StringSplit[
				text,
				"][",
				2
				]
		},
		XMLElement["img",
			{
				"src"->
					"ImageRefLink"@StringTrim[Last[bits],"]"],
				"alt"->
					StringTrim[First[bits],"!["]
				},
			{}
			]
		]


markdownToXMLFormat[
	"ImageRefLink",
	text_
	]:=
	With[{
		bits=
			StringSplit[
				text,
				"]:",
				2
				]
		},
		Sow[{"ImageRefLink", 
			StringTrim[First@bits, (Whitespace|"")~~"["]}->Last@bits];
			Nothing
		];
markdownToXMLFormat[
	"ImageRefLinkBlock",
	text_
	]:=
	markdownToXMLFormat["ImageRefLink", #]&/@
		Select[StringSplit[text, "\n"],
			Not@*StringMatchQ[Whitespace]
			]


(* ::Subsubsection::Closed:: *)
(*Fallback*)



markdownToXMLFormat[t_,text_String]:=
	XMLElement[t,{},{text}]


(* ::Subsubsection::Closed:: *)
(*markdownToXMLValidateXMLBlock*)



markdownToXMLValidateXMLBlock[s_]:=
	Quiet[
		Length@ImportString[s, {"HTML", "XMLObject"}][[2, 3, 1, 3]]===1
		]


(* ::Subsubsection::Closed:: *)
(*$markdownToXMLRules*)



(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLMeta*)



$markdownToXMLMeta=
	meta:(
		StartOfString~~
			((StartOfLine~~
					(Whitespace|"")~~
					Except[WhitespaceCharacter]..~~
					(Whitespace|"")~~":"~~Except["\n"]...~~"\n")..)
		):>
			{
				"Meta"->meta
				}


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLFenceBlock*)



$markdownToXMLFenceBlock=
	Shortest[
		fence:(
			StartOfLine~~(r:Repeated["`",{3,\[Infinity]}])~~
				Except["`"]~~s__~~Except["`"]~~
				StartOfLine~~(b:Repeated["`",{3,\[Infinity]}])
			)/;(
				StringLength[r]==StringLength[b]&&
					Length[StringSplit[fence,"\n"]]>2
				)
		]:>
		{
			"FenceBlock"->fence
			};


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLCodeBlock*)



$markdownToXMLCodeBlock=
	code:
		Longest[
			((StartOfString|"\n")~~"    "~~Except["\n"]..~~"\n")~~
				(((StartOfLine|(StartOfLine~~"    "~~Except["\n"]..))~~("\n"|EndOfString))...)
			]:>
		"CodeBlock"->code;


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLDelimiter*)



$markdownToXMLDelimiter=
	t:(
		(StartOfString|StartOfLine)~~
			(Whitespace|"")~~
			Repeated["-"|"_",{3,\[Infinity]}]~~
			Except["\n"]...
			):>
		"Delimiter"->t


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLHeader*)



$markdownToXMLHeader=
	t:(StartOfLine~~(Whitespace|"")~~Longest["#"..]~~Except["\n"]..):>
		"Header"->t


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLQuoteBlock*)



$markdownToXMLQuoteBlock=
	q:(
			(StartOfLine~~">"~~
				Except["\n"]..~~("\n"|EndOfString)
				)..
			):>
		"QuoteBlock"->q


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLItemBlock*)



$markdownToXMLLineIdentifier=
	("* "|"- "|((DigitCharacter..)~~". "))


$markdownToXMLBlankSpaces=	
	Repeated[
		("\n"~~(Except["\n"]..)~~EndOfLine),
		{0, 1}
		]~~("\n\n"|"")


$markdownToXMLItemLine=
	(
		(StartOfLine|StartOfString)~~
			(Whitespace?(StringFreeQ["\n"])|"")~~
			$markdownToXMLLineIdentifier~~
				Except["\n"]...~~(EndOfLine|EndOfString)
		);


$markdownToXMLItemSingle=
	$markdownToXMLItemLine~~
		$markdownToXMLBlankSpaces;
$markdownToXMLItemBlock=
	t:
		Repeated[
			$markdownToXMLItemSingle
			]:>
		"Item"->t


$markdownToXMLTwoWhitespaceItemLine=
	$markdownToXMLItemSingle/.
		Verbatim[(Whitespace?(StringFreeQ["\n"])|"")]:>
			Repeated[Except["\n", WhitespaceCharacter], {0,2}];


$markdownToXMLMultiItemBlock=
	t:(
		$markdownToXMLTwoWhitespaceItemLine~~
			Repeated[
				$markdownToXMLItemSingle~~
					("\n\n"|"")
				]
			):>
		"Item"->t


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLLink*)



markdownToXMLValidateLink[o_]:=
	StringCount[o, "["]==
		StringCount[o, "]"]


$markdownToXMLLink=
	o:(Except["!"]|StartOfLine|StartOfString)~~
		link:("["~~Except["\n"]..~~"]("~~Except[WhitespaceCharacter]..~~")")/;
			markdownToXMLValidateLink[o]:>
		{
			"Orphan"->o,
			"Link"->link
			}


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLImage*)



$markdownToXMLImage=
	img:("!["~~Except["\n"]..~~"]("~~Except[WhitespaceCharacter]..~~")")/;
		markdownToXMLValidateLink[img]:>
		"Image"->img


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLImageRef*)



$markdownToXMLImageRef=
	img:("!["~~Except["]"]..~~"]["~~Except["]"]..~~"]"):>
		"ImageRef"->img


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLImageRefLinkBlock*)



$markdownToXMLImageRefLinkBlock=
	img:Repeated[(
		(Whitespace|"")~~"["~~Except["]"]..~~"]:"~~(Whitespace|"")~~
			Except[WhitespaceCharacter]..)]:>
		"ImageRefLinkBlock"->img


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLImageRefLink*)



$markdownToXMLImageRefLink=
	img:((Whitespace|"")~~"["~~Except["]"]..~~"]:"~~(Whitespace|"")~~
		Except[WhitespaceCharacter]..~~(Whitespace|"")):>
		"ImageRefLink"->img


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLCodeLine*)



$markdownToXMLCodeLine=
	Shortest[
		o:(Except["`"]|StartOfLine|StartOfString)~~
			code:(
				(r:"`"..)~~
					Except["`"]~~__~~Except["`"]~~
					(b:"`"..)
				)/;StringLength[r]==StringLength[b]
		]:>
		{
			"Orphan"->o,
			"CodeLine"->code
			}


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLXMLLine*)



$markdownToXMLXMLLine=
	xml:("<"~~Except["<"]..~~"/>")|("<link"~~Except["<"]..~~">"):>
		("XMLLine"->xml)


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLXMLBlock*)



$markdownToXMLXMLBlock=
	cont:(
		"<"~~t:WordCharacter..~~__~~
			"<"~~(Whitespace|"")~~"/"~~t2:WordCharacter..~~(Whitespace|"")~~">"
		)/;t==t2&&
			StringCount[cont,
				"<"~~(Whitespace|"")~~(Whitespace|"")~~t]==
				StringCount[cont,"<"~~(Whitespace|"")~~"/"~~(Whitespace|"")~~t]&&
					markdownToXMLValidateXMLBlock[cont]:>
		("XMLBlock"->cont);


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLRawXMLBlock*)



$markdownToXMLRawXMLBlock=
	cont:(
		StartOfLine~~"<"~~t:WordCharacter..~~__~~
			"<"~~(Whitespace|"")~~"/"~~t2:WordCharacter..~~(Whitespace|"")~~">"
		)/;t==t2&&(*
			StringCount[cont, "<"]>2&&
			StringCount[cont, ">"]>2&&*)
			StringCount[cont,
				"<"~~(Whitespace|"")~~t
				]==
				StringCount[cont,
					"<"~~(Whitespace|"")~~"/"~~(Whitespace|"")~~t
					]&&markdownToXMLValidateXMLBlock[cont]:>
		("XMLBlock"->cont)


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLItalBold*)



$markdownToXMLItalBold=
	o:(Longest[a:("*"|"_")..]~~Shortest[t:Except["\n"]..]~~a_):>
		"ItalBold"->o


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLBlockRules*)



$markdownToXMLBlockRules={
	$markdownToXMLRawXMLBlock,
	$markdownToXMLFenceBlock,
	$markdownToXMLImageRefLinkBlock,
	$markdownToXMLMultiItemBlock,
	$markdownToXMLCodeBlock,
	$markdownToXMLDelimiter,
	$markdownToXMLHeader,
	$markdownToXMLItemBlock,
	$markdownToXMLQuoteBlock
	};


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLElementRules*)



$markdownToXMLElementRules={
	$markdownToXMLItalBold,
	$markdownToXMLLink,
	$markdownToXMLImageRef,
	$markdownToXMLImageRefLink,
	$markdownToXMLImage,
	$markdownToXMLCodeLine,
	$markdownToXMLXMLBlock,
	$markdownToXMLXMLLine
	};


(* ::Subsubsubsection::Closed:: *)
(*$markdownToXMLNewLineElements*)



$markdownToXMLNewLineElements=
	{
		"img"
		};


(* ::Subsubsection::Closed:: *)
(*markdownToXMLPrep*)



markdownToXMLPrep[text_String,rules:_List|Automatic:Automatic]:=
	With[{baseData=
		Fold[
			Flatten@
				Replace[
					Replace[#,
						{
							baseText_String:>{baseText},
							StringExpression[l__]:>
								List[l]
							}
						],
					{
						baseString_String:>
							Replace[StringReplace[baseString,#2],
								StringExpression[l__]:>
									List[l]
								]
						},
					1]&,
			text,
			Replace[rules,
				Automatic:>$markdownToXMLBlockRules
				]
			]
		},
		If[StringQ@baseData,
			baseData,
			Flatten@
				ReplaceAll[
					("Orphan"->_):>Sequence@@{}
					]@
				ReplaceRepeated[
					Flatten[List@@baseData],
					{a___,t_String,"Orphan"->o_,b___}:>
						{a,markdownToXMLPrep[t<>o],b}
					]
			]
		]


(* ::Subsubsection::Closed:: *)
(*markdownToXMLReinsertRefs*)



markdownToXMLReinsertRefs[{expr_, ops_}]:=
	With[{oppp=Association@Cases[Flatten@ops, _Rule|_RuleDelayed]},
	expr/.
		"ImageRefLink"[x_]:>
			Lookup[oppp, Key@{"ImageRefLink", x}, x]
		]


(* ::Subsubsection::Closed:: *)
(*markdownToXML*)



markdownToXML//Clear


markdownToXML[
	text_String,
	rules:_List|Automatic:Automatic,
	extraBlockRules:_List:{},
	extraElementRules:_List:{}
	]:=
	Block[{
		$markdownToXMLBlockRules=
			Join[extraBlockRules,$markdownToXMLBlockRules],
		$markdownToXMLElementRules=
			Join[extraElementRules,$markdownToXMLElementRules]
		},
		Flatten@
			Replace[
				markdownToXMLPrep[text,rules],{
					s_String:>
						If[rules===Automatic,
							Flatten@List@
								markdownToXMLPostProcess1[s],
							{s}
							],
					l_List:>
						Replace[l,
							{
								s_String:>
									If[rules===Automatic,
										markdownToXMLPostProcess1[s],
										s
										],
								(r_->s_):>
									markdownToXMLFormat[r,s]
								},
							1
							]
				}]
		]


(* ::Subsubsection::Closed:: *)
(*markdownToXMLPostProcess1*)



markdownToXMLPostProcess1[s_]:=
	SplitBy[
		Replace[
			DeleteCases[_String?(StringMatchQ[Whitespace])]@
				Flatten@List@
					markdownToXML[#,$markdownToXMLElementRules],
			{
				{e_XMLElement}:>e,
				e:Except[{_XMLElement}]:>
					XMLElement["p",{},
						Replace[Flatten@{e},
							str_String:>
								StringTrim[str],
							1
							]
						]
				}
			]&/@
			Select[Not@*StringMatchQ[Whitespace]]@
				StringSplit[s,"\n\n"]//Flatten,
		Replace[{
			XMLElement[Alternatives@@$markdownToXMLNewLineElements,__]:>
				RandomReal[],
			_->True
			}]
		]


(* ::Subsubsection::Closed:: *)
(*markdownToXMLPreProcess*)



markdownToXMLPreProcess[t_String]:=
	StringReplace[t,{
		("\n"~~Whitespace?(StringFreeQ["\n"])~~EndOfLine)->"\n",
		"\[IndentingNewLine]"->"\n\t",
		"\t"->"    ",
		"\[SpanFromLeft]"->"\[Ellipsis]"
		}]


(* ::Subsubsection::Closed:: *)
(*MarkdownToXML*)



Options[MarkdownToXML]=
	{
		"StripMetaInformation"->True,
		"HeaderElements"->{"meta", "style", "link", "title"},
		"BlockRules"->{},
		"ElementRules"->{}
		};
MarkdownToXML[
	s_String?(Not@*FileExistsQ),
	ops:OptionsPattern[]
	]:=
	With[{
		sm=TrueQ@OptionValue["StripMetaInformation"],
		he=OptionValue["HeaderElements"],
		er=Replace[OptionValue["ElementRules"],Except[_?OptionQ]:>{}],
		br=Replace[OptionValue["BlockRules"],Except[_?OptionQ]:>{}]
		},
		Replace[
			GatherBy[
				markdownToXMLReinsertRefs@
				Reap@
				markdownToXML[
					markdownToXMLPreProcess[s],
					Automatic,
					Join[
						br,
						If[sm,
							{
								$markdownToXMLMeta
								},
							{}
							]
						],
					er
					],
				StringMatchQ[Alternatives@@he]@*First
				],
		{
			{h_,b_}:>
				XMLElement["html",
					{},
					{
						XMLElement["head",{}, h],
						XMLElement["body",{}, b]
						}
					],
			{b_}:>
				XMLElement["html",
					{},
					{
						XMLElement["body",{},b]
						}
					]
			}]
		];
MarkdownToXML[f:(_File|_String?FileExistsQ)]:=
	MarkdownToXML@
		Import[f,"Text"]


End[];



