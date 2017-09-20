(* ::Package:: *)

$packageHeader

PackageScopeBlock[
	PacletServerPage::usage=
		"Generates a page laying out the available paclets on that server";
	PacletMarkdownNotebook::usage=
		"Generates a markdown notebook for the paclet";
	PacletMarkdownNotebookUpdate::usage=
		"Updates a markdown notebook for a paclet";
	$PacletServer::usage=
		"The configuration for the default paclet server";
	$PacletServerURL::usage=
		"The URL for the default paclet server";
	PacletServerFile::usage=
		"Finds a file on the default paclet server";
	]


PacletServerAdd::usage=
	"Adds a paclet to the default server";
PacletServerRemove::usage=
	"Removes a paclet from the default server";


PacletServerBuild::usage="Builds a paclet server and site";
PacletServerDeploy::usage="Deploys a paclet server";


Begin["`Private`"];


(*

The server structure looks like this:
	
	PacletServer
	
	   + Paclets
	   - PacletSite.mz
	   + content
	      + posts
	        - paclet1.nb
	        - paclet1.md
	        - paclet2.nb
	        - paclet2.md
	        ...
	      + pages
	        - about.md (??)
	        
	   - SiteConfig.m

When the server is built the Paclets and PacletSite.mz are copied to output for deployment

*)


$PacletServer//Clear


If[!OptionQ@$PacletServer,
	$PacletServer=
		{
			"ServerBase"->
				$WebSiteDirectory,
			"ServerExtension"->
				Nothing,
			"ServerName"->
				"PacletServer",
			Permissions->
				"Public",
			CloudConnect->
				"PacletsAccount"
			}
	]


(* ::Subsubsection::Closed:: *)
(*PacletServerURL*)



$PacletServerURL:=
	PacletSiteURL@
		FilterRules[$PacletServer,
			Options[PacletSiteURL]
			]


(* ::Subsubsection::Closed:: *)
(*PacletServerFile*)



PacletServerFile[fileName:_String|{__String}]:=
	With[{u=URLBuild@Flatten@{$PacletServerURL,fileName}},
		If[URLParse[u,"Scheme"]==="file",
			FileNameJoin@URLParse[u,"Path"],
			u
			]
		]


$PacletServerDirectory:=
	With[{u=$PacletServerURL},
		If[URLParse[u,"Scheme"]==="file",
			FileNameJoin@URLParse[u,"Path"],
			u
			]
		]


(* ::Subsubsection::Closed:: *)
(*PacletServerExposedPaclets*)



PacletServerExposedPaclets//Clear


PacletServerExposedPaclets[pacletSpecs:_Association|{___Association}]:=
	Map[Normal,
		Select[
			SortBy[
				DeleteDuplicatesBy[
					Reverse@SortBy[ToExpression@StringSplit[#Version,"."]&]@
						Flatten@{pacletSpecs},
					#Name&
					],
				#Name&
				],
			!StringEndsQ[#Name,("_Part"~~NumberString)|"_Index"]&
			]
		];
PacletServerExposedPaclets[d_Dataset]:=
	PacletServerExposedPaclets@Normal@d;


$PacletServerExposedPaclets:=
	PacletServerExposedPaclets@
		PacletSiteInfoDataset[PacletServerFile["PacletSite.mz"]];


(* ::Subsection:: *)
(*Single Page*)



$PacletServerTitle="Paclet Server";
$PacletServerDescription="";


pacletDownloadLine[
	pacletDownloadNB_,
	pacletDownloadURL_
	]:=
	XMLElement["div",
		{
			"class"->"paclet-download-line"
			},
		{
			XMLElement["a",
				{
					"href"->"wolfram+cloudobject:"<>pacletDownloadNB
					},
				{
					"Notebook"
					}
				],
			" | ",
			XMLElement["a",
				{
					"href"->pacletDownloadURL
					},
				{
					"Paclet"	
					}
				]
			}
		];


Options[pacletSectionXML]=
	Options[PacletExpression];
pacletSectionXML[site_,ops:OptionsPattern[]]:=
	XMLElement["div",
		{
			"class"->"paclet-section",
			"id"->OptionValue["Name"]
			},
		{
			XMLElement["h3",
				{
					"class"->"paclet-name"
					},
				{
					OptionValue["Name"],
					XMLElement["span",
						{
							"class"->"paclet-version-text"
							},
						{
							" v"<>OptionValue["Version"],
							Replace[
								Replace[OptionValue["WolframVersion"],
									Except[_String]:>OptionValue["MathematicaVersion"]
									],{
								s_String:>
									" | Mathematica "<>s,
								_->Nothing
								}]
							}
						]
				}],
			XMLElement["div",
				{
					"class"->"paclet-section-box"
					},
				{
					pacletDownloadLine[
						URLBuild[{
							site,
							OptionValue["Name"]<>"-"<>
								OptionValue["Version"]<>".nb"
							}],
						URLBuild[{
							site,
							"Paclets",
							OptionValue["Name"]<>"-"<>
								OptionValue["Version"]<>".paclet"
							}]
						],
					XMLElement[
						"p",
						{
							"class"->"paclet-download-description"	
							},
						{
							Replace[
								OptionValue["Description"],
								Automatic->""
								]
							}
						]
					}
				]
			}
		];


$pacletServerCSS=
"
body { 
	background: #fafafa ;
	margin: 0;
	}
.paclet-server-title {
	width: 100%;
	margin: 0;
	padding: 10;
	left: 0;
	top: 0;
	border-bottom: 1px solid #b01919 ;
	background: #8f3939; 
	color: #fafafa;
	box-shadow: 0px 2px 2px #901919 ;
 }
.paclet-server-description { 
	color: #505050;
	margin-left: 20px;
 }
.paclet-section {
	margin-top: 25;
	margin-left: 20px;
	width: 95%;
	margin-bottom: 15px;
	box-shadow: 1px 1px 1px gray ;
	border-radius: 5px;
	}
.paclet-name {
	min-height: 25px;
	margin: 0;
	padding: 10;
	color: #fafafa;
	background: #3f3f3f;
	border: solid 1px #3f3f3f;
	box-shadow: 1px 2px 2px #5f5f5f;
	border-top-left-radius: 5px;
	border-top-right-radius: 5px;
	}
.paclet-section-box { 
	border-left: solid 1px gray;
	border-right: solid 1px gray;
	border-bottom: solid 1px gray;
	border-bottom-left-radius: 5px;
	border-bottom-right-radius: 5px; 
	background: #f6f6f6;
	margin: 0;
	margin-top: 2;
	padding: 10;
	min-height: 125px;
 }
.paclet-version-text { 
	color: gray; 
	}
a:link {
	color: gray;
	}
a:hover {
	color: #cf3939;
	}
a:visited {
	color: #8f3939;
	}
";


Options[pacletServerXML]={
	"Title"->Automatic,
	"Description"->Automatic
	};
pacletServerXML[
	site_,
	pacletSpecs:_Association|{___Association},
	ops:OptionsPattern[]
	]:=
	XMLElement["html",{},{
		XMLElement["head",{},
			{
				XMLElement["title",{},{
					Replace[
						Replace[OptionValue["Title"],
							Automatic|Default->$PacletServerTitle
							],
						Except[_String]->""
						]
					}],
				XMLElement["style",
					{},
					{
						$pacletServerCSS
						}
					]
		}],
		XMLElement["body",
			{},
			Flatten@{
				XMLElement["div",
					{
						"class"->"paclet-server-title"
						},
					{
						XMLElement["h2",{},{
							Replace[
								Replace[OptionValue["Title"],
									Automatic|Default->$PacletServerTitle
									],
								Except[_String]->""
								]
							}]
						}
					],
				XMLElement[
					"div",
					{
						"class"->"paclet-server-description"
						},
					{
						XMLElement["p",{},{
							Replace[
								Replace[OptionValue["Description"],
									Automatic|Default->$PacletServerDescription
									],
								Except[_String]->""
								]
							}]
						}
					],
				pacletSectionXML[site,#]&/@
					PacletServerExposedPaclets[pacletSpecs]
				}
			]
		}];


(* ::Subsubsection::Closed:: *)
(*PacletServerPage*)



Options[PacletServerPage]=
	Join[{
		Permissions->Automatic
		},
		Options[CloudExport],
		Options[PacletSiteURL],
		Options[pacletServerXML],{
		"Extension"->"main.html"
		}];
PacletServerPage[
	ops:OptionsPattern[]
	]:=
	Block[{
		pacletServer=
			PacletSiteURL[FilterRules[{ops},Options@PacletSiteURL]],
		pacletServerPageXML:=
			htmlExportString@
				pacletServerXML[
					pacletServer,
					Normal@PacletSiteInfoDataset[pacletServer],
					FilterRules[{ops},Options@pacletServerXML]
					]
		},
		If[StringStartsQ[pacletServer,"file:"],
			Export[
				FileNameJoin@
					Append[
						URLParse[pacletServer,"Path"],
						OptionValue@"Extension"
						],
				pacletServerPageXML,
				"Text"
				],
			CloudExport[
				HTMLTemplateNotebook;
				pacletServerPageXML,
				"HTML",
				URLBuild@{
					pacletServer,
					OptionValue@"Extension"
					},
				FilterRules[{
					ops,
					Permissions->pacletStandardServerPermissions@OptionValue[Permissions]
					},
					Options@CloudExport]
				]
			]
	]


(* ::Subsection:: *)
(*Upload / Remove*)



(* ::Subsubsection::Closed:: *)
(*PacletServerAdd*)



Options[PacletServerAdd]=
	Options@PacletUpload;
PacletServerAdd[
	pacletSpecs:$PacletUploadPatterns,
	ops:OptionsPattern[]
	]:=
	PacletUpload[pacletSpecs,
		ops,
		Sequence@@
			FilterRules[
				Normal@$PacletServer,
				Options@PacletUpload
				],
		"UseCachedPaclets"->False,
		"UploadSiteFile"->True
		];


(* ::Subsubsection::Closed:: *)
(*PacletServerRemove*)



Options[PacletServerRemove]=
	Options@PacletServerRemove;
PacletServerRemove[
	pacletSpecs:$PacletRemovePatterns,
	ops:OptionsPattern[]
	]:=
	PacletRemove[
		pacletSpecs,
		Sequence@@
			FilterRules[
				Normal@$PacletServer,
				Options@PacletRemove
				]
		]


(* ::Subsection:: *)
(*Site*)



pacletMarkdownNotebookDownloadLink[a_]:=
	Cell[
		TextData[
			ButtonBox["Download",
				BaseStyle->"Hyperlink",
					ButtonData->
					{
						URLBuild@{
							"Paclets",
							Lookup[a,"Name"]<>"-"<>
								Lookup[a,"Version"]<>".paclet"
							},
						None
						}
				]
			],
		"Text",
		CellTags->"DownloadLink"
		]


pacletMarkdownNotebookDescriptionText[a_]:=
	Cell[Lookup[a,"Description",""],"Text",
		CellTags->"DescriptionText"
		]


pacletMarkdownNotebookBasicInfoSection[a_,thing_]:=
	With[{d=Lookup[a,thing]},
		If[StringQ@d,
			Cell[
				CellGroupData[{
					Cell[thing,"Subsubsection",CellTags->thing],
					Cell[d,"Text"]
					}]
				],
			Nothing
			]
		]


pacletMarkdownNotebookExtensionSection[extensionData_]:=
	Cell[
		CellGroupData@
			Flatten@{
				Cell["Extensions","Subsection"],
				KeyValueMap[
					Cell@
						CellGroupData[Flatten@{
							Cell[#,"Subsubsection"],
							Replace[Normal@#2,{
								((Prepend|Append)->_):>Nothing,
								(k_->v_):>
									Cell[ToString[k]<>": "<>ToString[v],"Item"]
								},
								1]
							}]&,
					extensionData
					]
				},
		CellTags->"Extensions"
		]


(* ::Subsubsection::Closed:: *)
(*PacletMarkdownNotebook*)



PacletMarkdownNotebook[
	a_Association
	]:=
	Notebook[
		{
			Cell[
				BoxData@ToBoxes@
					a,
				"Metadata"
				],
			Cell@CellGroupData@
				Flatten@{
					Cell[Lookup[a,"Name","Unnamed Paclet"],"Section"],
					pacletMarkdownNotebookDownloadLink[a],
					pacletMarkdownNotebookDescriptionText[a],
					Prepend[Cell["","PageBreak"]]@
					Riffle[
						{
							Cell[
								CellGroupData[{
									Cell["Basic Information","Subsection"],
									pacletMarkdownNotebookBasicInfoSection[a,"Name"],
									pacletMarkdownNotebookBasicInfoSection[a,"Version"],
									pacletMarkdownNotebookBasicInfoSection[a,"Description"],
									pacletMarkdownNotebookBasicInfoSection[a,"Creator"]
									}],
								CellTags->"BasicInformation"
								],
							If[KeyMemberQ[a,"Extensions"],
								pacletMarkdownNotebookExtensionSection[a["Extensions"]],
								Nothing
								]
							},
					Cell["","PageBreak"]
					]
				}
			},
		StyleDefinitions->FrontEnd`FileName[Evaluate@{$PackageName,"MarkdownNotebook.nb"}]
		];
PacletMarkdownNotebook[p_PacletManager`Paclet]:=
	PacletMarkdownNotebook[
		PacletInfoAssociation@p
		];
PacletMarkdownNotebook[f_String?FileExistsQ,a_]:=
	PacletMarkdownNotebookUpdate[f,a];
PacletMarkdownNotebook[f_String,a_]:=
	With[{nb=PacletMarkdownNotebook[a]},
		Switch[nb,
			_Notebook,
				If[!DirectoryQ@DirectoryName@f,
					CreateDirectory[DirectoryName@f,
						CreateIntermediateDirectories->True
						]
					];
				Export[f,nb],
			_,
				$Failed
			]
		]


(* ::Subsubsection::Closed:: *)
(*PacletMarkdownNotebookUpdate*)



PacletMarkdownNotebookUpdate[notebook_Notebook,a_]:=
	Module[{nb=notebook},
		nb=
			ReplaceAll[nb,
				Cell[BoxData[e_],"Metadata",___]:>
					Cell[
						BoxData@ToBoxes@
							Merge[{ToExpression[e],a},Last],
						"Metadata"
						]
				];
		nb=
			ReplaceAll[nb,
				Cell[___,CellTags->"DownloadLink",___]:>
					pacletMarkdownNotebookDownloadLink[a]
				];
		nb=
			ReplaceAll[nb,
				Cell[___,CellTags->"DescriptionText",___]:>
					pacletMarkdownNotebookDescriptionText[a]
				];
		Map[
			Function[
				nb=	
					ReplaceAll[nb,
						Cell[
							CellGroupData[{
								Cell[___,
									CellTags->#,
									___
									],
								___
								},
								___],
							___
							]:>
								pacletMarkdownNotebookBasicInfoSection[a,#]
						]
				],
			DeleteCases[Keys[a],
				"Extensions"|"Tags"|"Categories"|"Authors"
				]
			];
		nb=
			DeleteCases[nb,
				Cell[
					CellGroupData[{
						Cell[___,
							CellTags->
								Except[
									Alternatives@@
										Join[{
											"DescriptionText",
											"DownloadLink",
											"BasicInformation"
											},
											Keys[a]
											]
									],
							___
							],
						___
						},___],
					___
					],
				\[Infinity]
				];
		nb=
			ReplaceAll[nb,
				Cell[
					CellGroupData[{
						Cell[___,
							CellTags->"Extensions",
							___]
						},___
						],
					___
					]:>
					pacletMarkdownNotebookExtensionSection[a["Extensions"]]
				];
		nb
		];
PacletMarkdownNotebookUpdate[f_String?FileExistsQ,a_]:=
	With[{nb=Import[f]},
		Switch[nb,
			_Notebook,
				Export[
					f,
					PacletMarkdownNotebookUpdate[nb,a]
					],
			_,
				$Failed
			]
		]


(* ::Subsubsection::Closed:: *)
(*PacletServerInitialize*)



$PacletServerInitialized:=
	With[{d=$PacletServerDirectory},
		AllTrue[{d,FileNameJoin@{d,"content"},FileNameJoin@{d,"SiteConfig.wl"}},
			FileExistsQ
			]
		]


PacletServerInitialize[]:=
	If[!$PacletServerInitialized,
		With[{d=$PacletServerDirectory},
			If[!DirectoryQ@DirectoryName[d],	
				CreateDirectory@DirectoryName[d]
				];
			With[{tempDir=PackageFilePath["Resources","Templates","PacletServer"]},
				Map[
					With[{
						tf=FileNameJoin@{d,FileNameDrop[#,FileNameDepth[tempDir]]}
						},
						If[!FileExistsQ@tf,
							If[DirectoryQ@#,
								CopyDirectory[#,tf],
								CopyFile[#,tf]
								]
							]
						]&,
					FileNames["*",tempDir]
					];
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*PacletServerBuild*)



Options[PacletServerBuild]=
	Join[
		Options[WebSiteBuild],
		{
			"RegenerateContent"->True
			}
		];
PacletServerBuild[ops:OptionsPattern[]]:=
	With[{siteData=$PacletServerExposedPaclets},
		PacletServerInitialize[];
		If[OptionValue["RegenerateContent"],
			With[{nbout=PacletServerFile[{"content","posts",#Name<>".nb"}]},
				PacletMarkdownNotebook[
					nbout,
					Join[
						<|
							"Title"->Lookup[#,"Name","Unnamed Paclet"],
							"Categories"->"misc",
							"Slug"->Automatic,
							"Authors"->
								StringTrim@
									Map[
										StringSplit[#,"@"][[1]]&,
										StringSplit[Lookup[#,"Creator",""],","]
										],
							"Tags"->StringSplit[Lookup[#,"Keywords",""],","]
							|>,
						#
						]
					];
				Function[NotebookMarkdownSave[#];NotebookClose[#]]@
					NotebookOpen[nbout,Visible->False];
				]&/@Association/@siteData
			];
		With[{s=
			WebSiteBuild[
				$PacletServerDirectory,
				Sequence@@FilterRules[
					FilterRules[{ops},
						Options@WebSiteBuild
						],
					Except["AutoDeploy"]
					]
				]
			},
			If[TrueQ[OptionValue["AutoDeploy"]]||
				TrueQ@
					OptionValue["AutoDeploy"]===Automatic&&
						Lookup[
							Replace[Quiet@Import[PacletServerFile["SiteConfig.wl"]],
								Except[_Association]:>{}
								],
							"AutoDeploy"
							],
				PacletServerDeploy@
					Replace[
						OptionValue["DeployOptions"],
						Except[_?OptionQ]->{}
						],
				s
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*PacletServerDeploy*)



PacletServerDeploy::nobld=
	"PacletServerBuild needs to be called before PacletServerDeploy can work";


Options[PacletServerDeploy]=
	Options[WebSiteDeploy];
PacletServerDeploy[ops:OptionsPattern[]]:=
	If[DirectoryQ@PacletServerFile["output"],
		CopyFile[
			PacletServerFile["PacletSite.mz"],
			PacletServerFile[{"output","PacletSite.mz"}],
			OverwriteTarget->True
			];
		If[DirectoryQ@PacletServerFile[{"output","Paclets"}],
			DeleteDirectory[PacletServerFile[{"output","Paclets"}],
				DeleteContents->True]
			];
		CopyDirectory[
			PacletServerFile["Paclets"],
			PacletServerFile[{"output","Paclets"}]
			];
		(
			DeleteFile[
				PacletServerFile[{"output","PacletSite.mz"}]
				];
			DeleteDirectory[
				PacletServerFile[{"output","Paclets"}],
				DeleteContents->True
				];
			#
			)&@
			WebSiteDeploy[PacletServerFile["output"],
				FilterRules[{
					Normal@
						Merge[{
							ops,
							Lookup[
								Replace[Quiet@Import[PacletServerFile["SiteConfig.wl"]],
									Except[_?OptionQ]:>{}
									],
								"DeployOptions",
								{}
								],
							"ExtraFileNameForms"->
								{
									"PacletSite.mz",
									"*.paclet"
									}
							},
							First
							]
						},
						Options@PacletServerDeploy
						]
				],
		Message[PacletServerDeploy::nobld];
		$Failed
		]


End[];


