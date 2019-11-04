class User(Document):
    username = StringField(db_field='username', required=True, unique=True, max_length=30)
    email = EmailField(db_field='email', required=True, unique=True)
    watch_list = ListField(ReferenceField(User))
    
class WatchItem(Document):
    name = StringField(db_field='name', required=True)
    date_first_release = DateTimeField(db_field='date_first_release', required=False)

    meta = {'allow_inheritance': True}

class ConsoleWatchItem(WatchItem):
    generation = IntField(db_field='generation', required=False)
    abbreviation_official = StringField(db_field='abbreviation_official', required=False)
    developer = ReferenceField(Company)
    name_group = ReferenceField(NameGroup)
    name_prefix = StringField(db_field='name_prefix', required=False)
    name_suffix = StringField(db_field='name_suffix', required=False)
    name_alternatives = ListField(StringField(max_length=60))
    variations = ListField(ReferenceField(Variation))
    is_external_storage_compatible = BooleanField()

class GameWatchItem(WatchItem):
    platforms = ListField(ReferenceField(User))
    is_bootleg = BooleanField(db_field='is_bootleg', default=False)

class Company(Document):
    name = StringField(db_field='name', required=True)

class NameGroup(Document):
    name = StringField(db_field='name', required=True)

class Variation(Document):
    name = StringField(db_field='name', required=True)
    model_no = StringField(db_field='model_no', required=False)
    storage = EmbeddedDocumentListField(Storage)
    editions = EmbeddedDocumentListField(Edition)

class Storage(Document):
    capacity = IntField(db_field='capacity', required=True)
    unit = StringField(db_field='unit', required=False, max_length=2)
    style = StringField(db_field='style', required=False, max_length=50)

class Edition(Document):
    name = StringField(db_field='name', required=False)
    colors = ListField(ReferenceField(Color))

class Color(Document):
    name = StringField(db_field='name', required=True, max_length=30)
    similar_colors = ListField(ReferenceField(SimpleColor))

class SimpleColor(Document):
    name = StringField(db_field='name', required=True, max_length=20)