import 'dart:convert';
import 'dart:io';

void main() async {
  final filePath = 'Student.json';
  List<Student> students = [];

  // Đọc dữ liệu từ file JSON
  try {
    var file = File(filePath);
    if (file.existsSync()) {
      var jsonData = file.readAsStringSync();
      var jsonMap = jsonDecode(jsonData);
      var jsonList = jsonMap['students'] as List;
      students = jsonList.map((e) => Student.fromJson(e)).toList();
    }
  } catch (e) {
    print('Lỗi khi tải dữ liệu sinh viên: $e');
  }

  // Menu lựa chọn chức năng
  while (true) {
    print('Chọn chức năng:');
    print('1. Hiển thị toàn bộ sinh viên');
    print('2. Thêm sinh viên');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên theo tên hoặc ID');
    print('0. Thoát');
    
    String? choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        displayAllStudents(students);
        break;
      case '2':
        await addStudent(filePath, students);
        break;
      case '3':
        await updateStudent(filePath, students);
        break;
      case '4':
        await searchStudent(students);
        break;
      case '0':
        print('Thoát chương trình.');
        return;
      default:
        print('Lựa chọn không hợp lệ.');
    }
  }
}

void displayAllStudents(List<Student> students) {
  if (students.isEmpty) {
    print('Danh sách sinh viên trống.');
    return;
  }
  for (var student in students) {
    print('ID: ${student.id}, Tên: ${student.name}');
    for (var subject in student.subjects) {
      print('  Môn học: ${subject.name}, Điểm: ${subject.scores.join(", ")}');
    }
    print('---');
  }
}

Future<void> addStudent(String filePath, List<Student> students) async {
  print('Nhập ID sinh viên:');
  String? id = stdin.readLineSync();
  
  print('Nhập tên sinh viên:');
  String? name = stdin.readLineSync();
  
  List<Subject> subjects = [];
  
  while (true) {
    print('Nhập tên môn học (hoặc nhấn Enter để kết thúc):');
    String? subjectName = stdin.readLineSync();
    if (subjectName == null || subjectName.isEmpty) break;
    
    print('Nhập điểm môn học (cách nhau bằng dấu phẩy):');
    String? scoresInput = stdin.readLineSync();
    List<int> scores = scoresInput?.split(',').map((e) => int.parse(e.trim())).toList() ?? [];
    
    subjects.add(Subject(subjectName, scores));
  }
  
  if (id != null && name != null) {
    var newStudent = Student(id, name, subjects);
    students.add(newStudent);
    await saveStudents(filePath, students);
  }
}

Future<void> updateStudent(String filePath, List<Student> students) async {
  print('Nhập ID sinh viên cần sửa:');
  String? id = stdin.readLineSync();

  // Tìm sinh viên dựa trên ID. Nếu không tìm thấy, thông báo lỗi.
  Student? student;
  try {
    student = students.firstWhere((s) => s.id == id);
  } catch (e) {
    student = null; // Sinh viên không tồn tại.
  }

  if (student == null) {
    print('Sinh viên với ID này không tồn tại.');
    return;
  }
  
  print('Nhập tên mới (hoặc nhấn Enter để giữ nguyên):');
  String? newName = stdin.readLineSync();
  
  if (newName != null && newName.isNotEmpty) {
    student.name = newName;
  }
  
  print('Cập nhật môn học (nhấn Enter để kết thúc):');
  List<Subject> newSubjects = [];
  
  while (true) {
    print('Nhập tên môn học (hoặc nhấn Enter để kết thúc):');
    String? subjectName = stdin.readLineSync();
    if (subjectName == null || subjectName.isEmpty) break;
    
    print('Nhập điểm môn học (cách nhau bằng dấu phẩy):');
    String? scoresInput = stdin.readLineSync();
    List<int> scores = scoresInput?.split(',').map((e) => int.parse(e.trim())).toList() ?? [];
    
    newSubjects.add(Subject(subjectName, scores));
  }
  
  student.subjects = newSubjects;
  await saveStudents(filePath, students);
}

Future<void> searchStudent(List<Student> students) async {
  print('Nhập tên hoặc ID để tìm kiếm:');
  String? query = stdin.readLineSync();
  
  if (query != null && query.isNotEmpty) {
    var results = students.where((s) => s.id.contains(query) || s.name.contains(query)).toList();
    if (results.isEmpty) {
      print('Không tìm thấy sinh viên nào.');
    } else {
      displayAllStudents(results);
    }
  } else {
    print('Vui lòng nhập tên hoặc ID để tìm kiếm.');
  }
}

Future<void> saveStudents(String filePath, List<Student> students) async {
  var file = File(filePath);
  var jsonData = jsonEncode({'students': students.map((e) => e.toJson()).toList()});
  await file.writeAsString(jsonData);
}

class Subject {
  String name;
  List<int> scores;

  Subject(this.name, this.scores);

  Map<String, dynamic> toJson() => {
        'name': name,
        'scores': scores,
      };

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      json['name'],
      List<int>.from(json['scores']),
    );
  }
}

class Student {
  String id;
  String name;
  List<Subject> subjects;

  Student(this.id, this.name, this.subjects);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjects': subjects.map((subject) => subject.toJson()).toList(),
      };

  factory Student.fromJson(Map<String, dynamic> json) {
    var list = json['subjects'] as List;
    List<Subject> subjectList = list.map((i) => Subject.fromJson(i)).toList();
    return Student(
      json['id'],
      json['name'],
      subjectList,
    );
  }
}
