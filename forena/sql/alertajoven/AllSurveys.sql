-- ACCESS=access content
SELECT distinct
    `aj_survey`.`provider_id`,
    field_agency_name_value as `provider_name`,
    `aj_survey`.`uuid`,
    nombre, apellido, dob, sexo, provincia, municipio, BarrioComunidad, Estecolateralparticipante,
    `aj_survey`.`Fecha` as FechaDeEncuesta,
    `aj_survey`.`9Dóndenaciste`,
    `aj_survey`.`9Dóndenacisteotro`,
	`aj_survey`.`10Tienesunactadenacimientodominicana`,
    `aj_survey`.`101Tienescédula`,
    `aj_survey`.`102Cuálestunúmerodecédula`,
    `aj_survey`.`11Cuálestuidiomaprincipal`,
    `aj_survey`.`11IdiomaprincipalOtro`,
    `aj_survey`.`12Cuálestuestadocivil`,
    `aj_survey`.`13Tieneshijos`,
    `aj_survey`.`13Afecha1`,
    `aj_survey`.`13Afecha2`,
    `aj_survey`.`13Afecha3`,
    `aj_survey`.`13Afecha4`,        
    `aj_survey`.`13Asexo1`,    
	`aj_survey`.`13Asexo2`,
	`aj_survey`.`13Asexo3`,    
	`aj_survey`.`13Asexo4`,    
	`aj_survey`.`13AMismaCasa1`,    
	`aj_survey`.`13AMismaCasa2`,    
	`aj_survey`.`13AMismaCasa3`,    
	`aj_survey`.`13AMismaCasa4`,    
	`aj_survey`.`13AActaDeNacimiento1`,    
	`aj_survey`.`13AActaDeNacimiento2`,
	`aj_survey`.`13AActaDeNacimiento3`,    
	`aj_survey`.`13AActaDeNacimiento4`,
    `aj_survey`.`14Sabesleeryescribir`,
    `aj_survey`.`15Cuálesel`,
    `aj_survey`.`16Actualmenteestasasistiendoa`,
    `aj_survey`.`16ACuáleselnombredetuescuela`,
    `aj_survey`.`16ACuáleselnombredetuuniversidad`,
    `aj_survey`.`16BQuégradoestascursandoactualmente`,
    `aj_survey`.`16CCuálnivel`,
    `aj_survey`.`16DAquétandaasistes`,
    `aj_survey`.`17EnElUltimoAnoCuantaVecesHasFaltadoEscuela`,    
    `aj_survey`.`18Enlosúltimos12meseshassidosuspendidoadelaescuela`,
    `aj_survey`.`19ActualmenteEstasAsistiendoAlgunProgramaDeEduca`,  
    `aj_survey`.`20Hasrepetidoalgúncursoenlaescuela`,
    `aj_survey`.`20ASilarespuestaesafirmativacuálescursos`,
    `aj_survey`.`21Hascompletadoalgúncursotécnico`,
    `aj_survey`.`21ASilarespuestaesafirmativacuálescursos`,
    `aj_survey`.`22Actualmentetededicasa`,
    `aj_survey`.`23Hassidos`,
    `aj_survey`.`Megustaríaleermejor`,
    `aj_survey`.`Megustaríamejorarenmatemáticas`,
    `aj_survey`.`Megustaríamejorarenciencias`,
    `aj_survey`.`Megustaríaestarenlaescuela`,
    `aj_survey`.`Megustaríahablarelinglés`,
    `aj_survey`.`Megustaríasabermásacercadeempleos`,
    `aj_survey`.`Megustaríaterminarlabásica`,
    `aj_survey`.`Megustaríaterminarelbachillerato`,
    `aj_survey`.`MegustaríairalaUniversidad`,
    `aj_survey`.`Megustaríallevarmemejorconmismaestros`,
    `aj_survey`.`Megustaríasentirmemásseguroenlaescuela`,
    `aj_survey`.`Megustaríahablarmejorelespañol`,
    `aj_survey`.`Megustaríamejorarmiscalificaciones`,
    `aj_survey`.`Notengoningunameta`,
    `aj_survey`.`Otrasmetas`,
    `aj_survey`.`25Hasreali`,
    `aj_survey`.`26Durantel`,
    `aj_survey`.`26ADescribeloquehaceseneltrabajoactual`,
    `aj_survey`.`27Mes`,
    `aj_survey`.`27Año`,
    `aj_survey`.`28Enquélugarrealizasestetrabajo`,
    `aj_survey`.`28EnquélugarOtros`,
    `aj_survey`.`29Cuántashorastrabajasenundía`,
    `aj_survey`.`30Cuántosdíastrabajasenunasemana`,
    `aj_survey`.`31Enpromediocuántoganasenunasemana`,
    `aj_survey`.`32Enestetrabajotúeres`,
    `aj_survey`.`32OtroTúeres`,
    `aj_survey`.`33Actualme`,
    `aj_survey`.`33ADescribeloquehacesenestetrabajo`,
    `aj_survey`.`34Mes`,
    `aj_survey`.`34Año`,
    `aj_survey`.`35Enquélugarrealizasestetrabajo`,
    `aj_survey`.`35EnquélugarrealizasestetrabajoOtros`,
    `aj_survey`.`36Cuántashorastrabajasenundía`,
    `aj_survey`.`37Cuántosdíastrabajasenunasemana`,
    `aj_survey`.`38Enestetrabajotúeres`,
    `aj_survey`.`38EnestetrabajotúeresOtro`,
    `aj_survey`.`39Hasbusca`,
    `aj_survey`.`40Hasparti`,
    `aj_survey`.`41Conquéfr`,
    `aj_survey`.`42Conquéfr`,
    `aj_survey`.`43Enquémedidatuvidahasidoafectadaporladelincuencia`,
    `aj_survey`.`44Entuopin`,
    `aj_survey`.`45Tepreocu`,
    `aj_survey`.`46Lapreocu`,
    `aj_survey`.`47AUnpolicíameamenazóverbalmente`,
    `aj_survey`.`47BUnpolicíamecobródinerosinjustificación`,
    `aj_survey`.`47CUnpolicíamequitóalgoquemepertenecia`,
    `aj_survey`.`47DUnpolicíamemaltratófísicamente`,
    `aj_survey`.`48Hassidot`,
    `aj_survey`.`49Hassidodetenidoporlapolicíaporalgúnmotivo`,
    `aj_survey`.`49ASucedióestoenlosúltimos12meses`,
    `aj_survey`.`50Hassidod`,
    `aj_survey`.`50ASucedióestoenlosúltimos12meses`,
    `aj_survey`.`51Algunode`,
    `aj_survey`.`51ASucedióestoenlosúltimos12meses`,
    `aj_survey`.`52Enlosúlt`,
    `aj_survey`.`53Enlosúlt`,
    `aj_survey`.`54Enlosúlt`,
	`aj_survey`.`54ACasa`,
    `aj_survey`.`54AEscuela`,
    `aj_survey`.`54ABarrio`,
    `aj_survey`.`55Enlosúlt`,
    `aj_survey`.`55ACasa`,
    `aj_survey`.`55AEscuela`,
    `aj_survey`.`55ABarrio`,
    `aj_survey`.`56Enlosúlt`,
    `aj_survey`.`56ACasa`,
    `aj_survey`.`56AEscuela`,
    `aj_survey`.`56ABarrio`,
    `aj_survey`.`57Enlosúlt`,
    `aj_survey`.`57ACasa`,
    `aj_survey`.`57AEscuela`,
    `aj_survey`.`57ABarrio`,
    `aj_survey`.`58Enlosúlt`,
    `aj_survey`.`58ACasa`,
    `aj_survey`.`58AEscuela`,
    `aj_survey`.`58ABarrio`,
    `aj_survey`.`59Enlosúlt`,
    `aj_survey`.`59ACasa`,
    `aj_survey`.`59AEscuela`,
    `aj_survey`.`59ABarrio`,
    `aj_survey`.`60Enlosúlt`,
    `aj_survey`.`60ACasa`,
    `aj_survey`.`60AEscuela`,
    `aj_survey`.`60ABarrio`,
    `aj_survey`.`61Enlosúlt`,
    `aj_survey`.`61ACasa`,
    `aj_survey`.`61AEscuela`,
    `aj_survey`.`61ABarrio`,
    `aj_survey`.`62Enlosúlt`,
    `aj_survey`.`62ACasa`,
    `aj_survey`.`62AEscuela`,
    `aj_survey`.`62ABarrio`,
    `aj_survey`.`63Enlosúlt`,
    `aj_survey`.`63ACasa`,
    `aj_survey`.`63AEscuela`,
    `aj_survey`.`63ABarrio`,
    `aj_survey`.`64Enlosúlt`,
    `aj_survey`.`65Hasdañad`,
    `aj_survey`.`66Algunavezhassidoatacadoorobado`,
    `aj_survey`.`67Algunavezhasatacadoorobadoaalguien`,
    `aj_survey`.`68Algunavezhassidosecuestrado`,
    `aj_survey`.`69Algunavezhassecuestradoaalguien`,
    `aj_survey`.`70Algunave`,
    `aj_survey`.`71Algunave`,
    `aj_survey`.`72Algunavezhasvendidooayudadoavenderdrogas`,
    `aj_survey`.`73Hasestadoinvolucradoenunapandilla`,
    `aj_survey`.`73AActualm`,
    `aj_survey`.`74Comparte`,
    `aj_survey`.`74ACasa`,
    `aj_survey`.`74AEscuela`,
    `aj_survey`.`74ABarrio`,
    `aj_survey`.`75Enlosúlt`,
    `aj_survey`.`76Algunave`,
    `aj_survey`.`76AEnlosúl`,
    `aj_survey`.`76BEnLosUltimos12MesesHasTomado5Vasos`,
    `aj_survey`.`77Hasproba`,
    `aj_survey`.`78Hasusado`,
    `aj_survey`.`79AMarihuana`,
    `aj_survey`.`79BCrack`,
    `aj_survey`.`79CCocaínaenpolvo`,
    `aj_survey`.`79DHeroína`,
    `aj_survey`.`79EMetanfetaminaocristal`,
    `aj_survey`.`79FxtasisMDMA`,
    `aj_survey`.`79GInhalantescomopegamentocementopinturaspray`,
    `aj_survey`.`79IOtrosespecifica`,
    `aj_survey`.`80AMarihuana`,
    `aj_survey`.`80BCrack`,
    `aj_survey`.`80CCocaínaenpolvo`,
    `aj_survey`.`80DHeroína`,
    `aj_survey`.`80EMetanfetaminaocristal`,
    `aj_survey`.`80FxtasisMDMA`,
    `aj_survey`.`80GInhalantescomopegamentocementopinturaspray`,
    `aj_survey`.`80IOtrosespecifica`,
    `aj_survey`.`81AMarihuana`,
    `aj_survey`.`81BCrack`,
    `aj_survey`.`81CCocaínaenpolvo`,
    `aj_survey`.`81DHeroína`,
    `aj_survey`.`81EMetanfetaminaocristal`,
    `aj_survey`.`81FxtasisMDMA`,
    `aj_survey`.`81GInhalantes`,
    `aj_survey`.`81HOtraespecifica`,
    `aj_survey`.`82Algunavezhastenidorelacionessexuales`,
    `aj_survey`.`83Quéedadtenías`,
    `aj_survey`.`84Conquiéneshastenidorelacionessexuales`,
    `aj_survey`.`85Concuánt`,
    `aj_survey`.`86Laúltima`,
    `aj_survey`.`87ANoutilicéningún`,
    `aj_survey`.`87BCondón`,
    `aj_survey`.`87CCondónfemenino`,
    `aj_survey`.`87DPíldoraanticonceptiva`,
    `aj_survey`.`87ERitmoma`,
    `aj_survey`.`87FRetirod`,
    `aj_survey`.`87GMelamujereslactando`,
    `aj_survey`.`87HDIUcomoMirenaoParagard`,
    `aj_survey`.`87IInyecci`,
    `aj_survey`.`87JImplant`,
    `aj_survey`.`87KEsterilizaciónfemenina`,
    `aj_survey`.`87LEsterilizaciónmasculina`,
    `aj_survey`.`87MNoséInseguro`,
    `aj_survey`.`87NOtro`,
    `aj_survey`.`88Algunave`,
    `aj_survey`.`89Algunave`,
    `aj_survey`.`89ASilares`,
    `aj_survey`.`90Siquisie`,
    `aj_survey`.`91Siquisie`,
    `aj_survey`.`92Tesiente`,
    `aj_survey`.`93Algunave`,
    `aj_survey`.`94Algunave`,
    `aj_survey`.`94AOrientadoraoPsicólogoadelaescuela`,
    `aj_survey`.`94APadreoMadre`,
    `aj_survey`.`94APromotoradeSalud`,
    `aj_survey`.`94AProfesoradelaescuela`,
    `aj_survey`.`94AInternet`,
    `aj_survey`.`94AAmigos`,
    `aj_survey`.`95Algunave`,
    `aj_survey`.`94AOtroEspecifique`,
    `aj_survey`.`95AOrientadoraoPsicólogoadelaescuela`,
    `aj_survey`.`95APadreoMadre`,
    `aj_survey`.`95APromotoradeSalud`,
    `aj_survey`.`95AProfesoradelaescuela`,
    `aj_survey`.`95AInternet`,
    `aj_survey`.`95AAmigos`,
    `aj_survey`.`95AOtroEspecifique`,
    `aj_survey`.`96Algunave`,
	`aj_survey`.`96AOrientadoraoPsicólogoadelaescuela`,
	`aj_survey`.`96APadreoMadre`,
	`aj_survey`.`96APromotoradeSalud`,
	`aj_survey`.`96AProfesoradelaescuela`,
	`aj_survey`.`96AInternet`,
	`aj_survey`.`96AAmigos`,
	`aj_survey`.`96AOtroEspecifique`,
-- 	`aj_survey`.`id`,
--     `aj_survey`.`_id`,
--     `aj_survey`.`_rev`,
    `aj_survey`.`createdAt`,
    `aj_survey`.`lastModifiedAt`,
    
--     `aj_survey`.`created`,
--     `aj_survey`.`changed`,
--     `aj_survey`.`Completado`,
--     `aj_survey`.`question`,
    `aj_survey`.`user_name`
FROM `bitnami_drupal7`.`aj_survey` join `bitnami_drupal7`.field_data_field_agency_name on (aj_survey.provider_id=entity_id) 
join `bitnami_drupal7`.`aj_registration` using(uuid) 
where 
1 =1
--IF=:provider_id
and aj_survey.provider_id in (:provider_id)

--IF=:from_date
and aj_survey.Fecha >= :from_date
--END
--IF=:to_date
and aj_survey.Fecha <= :to_date
--END

--IF=:from_date_creation
and SUBSTRING(aj_survey.createdAt, 1, 10) >= :from_date_creation
--END
--IF=:to_date_creation
and SUBSTRING(aj_survey.createdAt, 1, 10) <= :to_date_creation
--END

limit 50