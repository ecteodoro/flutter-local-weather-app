class Person {
  String name;
  int age;
  
  Person(String name, int age) {
    this.name = name;
    this.age = age;
  }
  
  bool isOld() {
    if (age > 60) {
      return true;
    }
    return false;
  }
  
}

class PetOwner extends Person {
  List pets;
  
  PetOwner(String name, int age) :super(name, age) {
    this.pets = new List();
  }
  
  void addPet(Pet pet) {
    pets.add(pet);
  }
  
  List myPets() {
    return pets;
  }
}

class Pet {
  String name;
  String sound;
  
  Pet(this.name, this.sound);
}

void main() {
  PetOwner john = PetOwner('John', 35);
  PetOwner rachel = PetOwner('Rachel', 67);
  
  print('Is John old? ${john.isOld()}');
  print('Is Rachel old? ${rachel.isOld()}');
  
  var cat = Pet('Felix', 'meow');
  var dog = Pet('Odie', 'bark');
  var cow = Pet('Rosie', 'mooo');
  
  john.addPet(cat);
  john.addPet(cow);
  
  rachel.addPet(dog);
  
  john.myPets().forEach((pet) =>
    print('John has a pet named ${pet.name} and it ${pet.sound}s'));
  
  rachel.myPets().forEach((pet) =>
    print('Rachel has a pet named ${pet.name} and it ${pet.sound}s'));
}
