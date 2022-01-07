#!/usr/bin/python
# An example for factory classes.
#
# Links:
#   http://python-3-patterns-idioms-test.readthedocs.io/en/latest/Factory.html
#   https://krzysztofzuraw.com/blog/2016/factory-pattern-python.html

import os, tarfile
from zipfile import ZipFile

### SIMPLE FACTORY OBJECT ###

class BaseArchive(object):
    EXTENSION = None

    def __init__(self, location_path, files_to_pack):
        self.location_path = location_path
        self.files_to_pack = files_to_pack

    def generate(self):
        raise NotImplementedError()
    # Better than Not Implemented:
    # from abc import ABCMeta, abstractmethod
    # @abstractmethod
    # def generate(self): pass

    @classmethod
    def extension_matches(cls,extension):
        return extension == cls.EXTENSION



class ZIPArchive(BaseArchive):
    EXTENSION = '.zip'

    def generate(self):
        with ZipFile(self.location_path, 'w') as zip_file:
            for file_ in self.files_to_pack:
                zip_file.write(file_)


class TARArchive(BaseArchive):
    EXTENSION = '.tar'

    def generate(self):
        with tarfile.open(self.location_path, 'w') as tar_file:
            for file_ in self.files_to_pack:
                tar_file.add(file_)


class ArchiveManager(object):
    # (Good idea to put the subclasses (ZIPArichve, TARArchive) here,
    #+if you want to prevent direct access)

    ARCHIVE_ENGINES = BaseArchive.__subclasses__()

    def __init__(self, location_path, files_to_pack):
        self.location_path = location_path
        self.extension = os.path.splitext(location_path)[1]
        self.files_to_pack = files_to_pack
        self.archive_engine = self.choose_archive_engine()

    def choose_archive_engine(self):
        for engine in self.ARCHIVE_ENGINES:
            if engine.extension_matches(self.extension):
                return engine(self.location_path, self.files_to_pack)

    def create_archive(self):
        self.archive_engine.generate()


if __name__ == '__main__':
    import tempfile, time

    for atype in ['.zip', '.tar']:
        fd, path = tempfile.mkstemp(suffix='.txt')
        try:
            with os.fdopen(fd, 'w') as tmp:
                tmp.write('Some random text to put in '+ atype[1:])
                tmp.flush()
                if atype == '.zip':
                    archive = ZIPArchive( os.path.join(os.getcwd(),
                                          'zip.zip'), [path]          )
                else:
                    archive = TARArchive( os.path.join(os.getcwd(),
                                          'tar.tar'), [path]          )
                archive.generate()
        finally:
            os.remove(path)

    # Use the ArchiveManager factory to create the archive
    archive = ArchiveManager( os.path.join(os.getcwd(), 'zips.tar'),
                              ['zip.zip', 'tar.tar']                  )
    archive.create_archive()
    exit(0)



### POLYMORPHIC FACTORY ###

import random


class ShapeFactory:
    factories = {}
    def addFactory(id, shapeFactory):
        ShapeFactory.factories.put[id] = shapeFactory
    addFactory = staticmethod(addFactory)
    # A Template Method:
    def createShape(id):
        if not ShapeFactory.factories.has_key(id):
            ShapeFactory.factories[id] = \
              eval(id + '.Factory()') # Dangerous eval here!
        return ShapeFactory.factories[id].create()
    createShape = staticmethod(createShape)


class Shape(object): pass


class Circle(Shape):
    def draw(self): print("Circle.draw")
    def erase(self): print("Circle.erase")
    class Factory:
        def create(self): return Circle()


class Square(Shape):
    def draw(self):
        print("Square.draw")
    def erase(self):
        print("Square.erase")
    class Factory:
        def create(self): return Square()


def shapeNameGen(n):
    types = Shape.__subclasses__()
    for i in range(n):
        yield random.choice(types).__name__


if __name__ == '__main__':
    shapes = [ ShapeFactory.createShape(i) for i in shapeNameGen(7)]

    for shape in shapes:
        shape.draw()
        shape.erase()

    exit(0)



### Simplified Abstract Factory ###

class Kitty:
    def interactWith(self, obstacle):
        print("Kitty has encountered a",
        obstacle.action())

class KungFuGuy:
    def interactWith(self, obstacle):
        print("KungFuGuy now battles a",
        obstacle.action())

class Puzzle:
    def action(self): print("Puzzle")

class NastyWeapon:
    def action(self): print("NastyWeapon")

# Concrete factories:
class KittiesAndPuzzles:
    def makeCharacter(self): return Kitty()
    def makeObstacle(self): return Puzzle()

class KillAndDismember:
    def makeCharacter(self): return KungFuGuy()
    def makeObstacle(self): return NastyWeapon()

class GameEnvironment:
    def __init__(self, factory):
        self.factory = factory
        self.p = factory.makeCharacter()
        self.ob = factory.makeObstacle()
    def play(self):
        self.p.interactWith(self.ob)

if __name__ == '__main__':
    g1 = GameEnvironment(KittiesAndPuzzles())
    g2 = GameEnvironment(KillAndDismember())
    g1.play()
    g2.play()
    exit(0)
