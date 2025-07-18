
&НаКлиенте
Процедура ОбработатьДанные(Результат, ДополнительныеПараметры) Экспорт

	ОтключитьОбработчикОжидания("ОбработчикОжиданияИндикатор");
	
	Если Результат = Неопределено Тогда
		Возврат;
	ИначеЕсли Результат.Статус = "Ошибка" Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Результат.ПодробноеПредставлениеОшибки);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ВыполнитьФоновоеЗаданиеНаСервере(ПараметрыЗапуска, УникальныйИдентификатор)
	
	НаименованиеЗадания = "Создать реализации";

	ВыполняемыйМетод = "ВКМ_ДлительныеОпреации.ПроверитьСоздатьРеализации";
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НаименованиеЗадания;
	ПараметрыВыполнения.ЗапуститьВФоне 	= Истина;
	ПараметрыВыполнения.Вставить("ИдентификаторФормы", УникальныйИдентификатор); 
	
	СтруктураФоновогоЗадания = ДлительныеОперации.ВыполнитьВФоне(ВыполняемыйМетод, ПараметрыЗапуска, ПараметрыВыполнения);
	
	Возврат СтруктураФоновогоЗадания;
	
КонецФункции	

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	ЗаполнитьДействующиеДоговорыАО();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДействующиеДоговорыАО()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДоговорыКонтрагентов.Ссылка КАК Договор,
	               |	РеализацияТоваровУслуг.Ссылка КАК Реализация
	               |ИЗ
	               |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	               |		ПО (РеализацияТоваровУслуг.Договор = ДоговорыКонтрагентов.Ссылка)
	               |ГДЕ
	               |	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	               |	И ДоговорыКонтрагентов.ДатаНачалаДействия <= &ДатаНачала
	               |	И ДоговорыКонтрагентов.ДатаОкончанияДействия >= &ДатаОкончания";
	Запрос.УстановитьПараметр("ВидДоговора",Перечисления.ВидыДоговоровКонтрагентов.АбонентскоеОбслуживание);
	Запрос.УстановитьПараметр("ДатаНачала", Объект.Период.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", НачалоДня(Объект.Период.ДатаОкончания));
	Выборка = Запрос.Выполнить().Выгрузить();
	Объект.Акты.Загрузить(Выборка);	
КонецПроцедуры	

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.Период.ДатаНачала = НачалоМесяца(ТекущаяДата());
	Объект.Период.ДатаОкончания = КонецМесяца(ТекущаяДата());
	ЗаполнитьДействующиеДоговорыАО();
КонецПроцедуры

&НаКлиенте
Процедура СоздатьРеализации(Команда)
	ИДЗадания = "";
	Индикатор = 0;
	СтрокаСостояния = "";
	
	ПараметрыЗапуска = Новый Структура;
	ПараметрыЗапуска.Вставить("Период", Объект.Период);
	
	СтруктураФоновогоЗадания = ВыполнитьФоновоеЗаданиеНаСервере(ПараметрыЗапуска, УникальныйИдентификатор);
	ИДЗадания 	= СтруктураФоновогоЗадания.ИдентификаторЗадания;
	
	ПараметрыОжидания  = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.Интервал  = 2;
	
	ДлительныеОперацииКлиент.ОжидатьЗавершение(СтруктураФоновогоЗадания, Новый ОписаниеОповещения("ОбработатьДанные", ЭтотОбъект), ПараметрыОжидания);
КонецПроцедуры
