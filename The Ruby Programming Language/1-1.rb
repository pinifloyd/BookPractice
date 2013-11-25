#
# В этом модуле определяется класс Sudoku::Pazzle, отображающий пазл Sudoku
# 9x9, а так же определяющий классы исключений, выдаваемых при неверном вводе
# данных и излишне ограниченных пазлов. В этом модуле для решения пазла также
# определяется метод Sudoku.solve. Метод решения использует метод Sudoku.scan,
# который также здесь определен.
#
# Этот модуль можно использовать для решения пазлов Sudoku, применив:
#   require 'sudoku'
#   puts Sudoku.solve(Sudoku::Puzzle.new(ARGF.readlines))
#
module Sudoku
  #
  # Класс Sudoku::Puzzle представляет состояние пазла Sudoku 9х9.
  #
  # Некоторые определения и термины, используемые в этой реализации:
  # - каждый элемент пазла называется 'cell (ячейка)';
  # - Строки и столбцы нумеруются от 0 до 8, а координаты [0, 0] относятся к
  #   ячейке в верхнем левом углу пазла;
  # - Девять квадратов 3х3, известных как 'boxes', также пронумерованы от 0 до
  #   8, счет ведется слева на право и сверху вниз. Нулевым является левый
  #   верхний квадрат. Квадрат сверху справа имеет номер 2. Квадрат,
  #   расположенный посредине, имеет номер 4. Квадрат в левом нижнем углу имеет
  #   номер 8.
  #
  # Создайте новый пазл, используя Sudoku::Puzzle.new, определите начальное
  # состояние в виде строки или массива строк. В строке(ах) нужно использовать
  # символы от 1 до 9 для заданных значений, и '.' для ячеек, значение которых
  # не указано. Неотображаемые символы при вводе игнорируются.
  #
  # Чтение и запись в отдельные ячейки пазла осуществляются посредством
  # операторов [] и []=, которые ожидают наличие двумерной [строка, столбец]
  # индексации. В этих методах для содержимого ячеек используются числа (а не
  # символы) от 0 до 9. 0 представляет неизвестное значение.
  #
  # Предикат has_duplicates? возвращает true если, пазл составлен неверно из-за
  # того, что любая строка, столбец или квадрат содержат одну и туже цифру
  # дважды.
  #
  # Метод each_unknown является итератором, перебирающим ячейки пазла и
  # вызывающим связанный с ним блок для каждой ячейки, чье значение не известно.
  #
  # Метод possible возвращает целочисленный массив, имеющий диапозон 1..9.
  # Элементы массива состоят только из тех значений, которые разрешены в
  # конкретной ячейке. Если этот массив пуст, то пазл уже полностью определен и
  # и не может быть решен. Если массив содержит всего один элемент, значит этот
  # элемент должен быть значением для этой ячейки пазла.
  #
  class Puzzle
    #
    # Эти константы используются для переводов между внешним представлением
    # строки пазла и ее внутренним представлением.
    #
    ASCII = ".12345678"
    BIN   = "\000\001\002\003\004\005\006\007\010\011"

    #
    # Это инициализационный метод класса. Он вызывается автоматически для нового
    # экземпляра Puzzle, создаваемого при помощи Puzzle.new. Вводимый пазл
    # передается в виде массива строк или в виде отдельной строки. При этом
    # используются цифры в кодировке ASCII от 1 до 9, а для неизвестных ячеек
    # используется символ '.'. Неотображаемые символы, включая символы новой
    # строки, будут удалены.
    #
    def initialize(lines)
      # Если аргумент похож на массив строк, то объединение их в одну строку.
      # Иначе предположение, что это строка и создание ее закрытой копии.
      s = lines.respond_to?(:join) ? lines.join : lines.dup

      #
      # Удаление из данных неотображаемых символов (включая символы новой строки).
      # Знак '!' в gsub! показывает, что это метод-мутатор, непосредственно
      # изменяющий саму строку, а не создающий ее копию. /\s/ - регулярное выражение,
      # соответствующее любому неотображаемому символу.
      #
      s.gsub!(/\s/, '')

      #
      # Выдача исключения, если вводимые данные имеют неверный размер. Заметьте, что
      # мы используем unless вместо if и используем его в форме модификатора.
      #
      raise Invalid, 'Пазл имеет неверный размер' unless s.size == 81

      #
      # Проверка на недопустимые символы, и сохранение положения первого из них.
      # Замктьте, что присваивание и проверка значения, на основе которого оно
      # осуществляется, проводятся одновременно.
      #
      if i = s.index(/[^123456789\.]/)
        #
        # Включение недопустимого символа в сообщение об ошибке. Обратите внимание
        # на Ruby-выражение внутри #{} в строковом литерале.
        #
        raise Invalid, "Недопустимый символ #{s[i, 1]} в пазле"
      end

      #
      # Следующие две строчки превращают нашу строку в ASCII-символов в целочисленный
      # массив, используя два мощных метода объекта String. Получившийся массив
      # сохраняется в переменной экземпляра @grid. Число 0 используется для
      # представления неизвестного значения.
      #
      s.tr!(ASCII, BIN)      # Перевод ASCII-символов в байты
      @grid = s.unpack('c*') # Распаковка байтов в массив чисел

      #
      # Проверка строк, столбцов и квадратов на отсутствие дубликатов.
      #
      raise Invalid, 'В исходном пазле имеются дубликаты' if has_duplicates?
    end

    #
    # Возвращение состояния пазла в виде строкового значения из 9 строк по 9 символов
    # (плюс символ новой строки) в каждой.
    #
    def to_s
      #
      # Этот метод реализован в одной магической строке Ruby, которая повторяет в
      # обратном порядке действия метода initialize(). Возможно, написание подобного
      # лаконического кода и не является лучшим стилем программирования, но зато с его
      # помощью демонстрируется мощность и выразительность языка.
      #
      # Если провести анализ, то приведенная ниже строка работает следующим образом:
      # (0..8).collect вызывает код в фигурных скобках девять раз - по одному разу для
      # для каждой строки - и собирает значения, возвращаемые этим кодом в массив. Код
      # в фигурных скобках берет подмассив пазла, представляющий отдельную строку, и
      # запаковывает его числа в строку. Метод join() объединяет элементы массива в
      # единую строку, перемежая их символами новой строки. И наконец, метод tr()
      # преобразовывает представление строки двоичных чисел в ASCII-цифры.
      #
      (0..8).collect{ |r| @grid[r*9,9].pack('c9') }.join('\n').tr(BIN, ASCII)
    end

    #
    # Возвращает дубликат этого объекта Puzzle. Этот метод переопределяет Object.dup
    # для копирования массива @grid.
    #
    def dup
      copy = super      # Создание поверхностной копии за счет вызова Object.dup
      @grid = @grid.dup # Создание новой копии внутренних данных
      copy              # Возвращение скопированного объекта
    end

    #
    # Мы переопределяем оператор доступа к массиву, чтобы получить возможность доступа
    # к отдельной ячейке пазла. Пазл двумерный и должен быть индексирован координатами
    # строки и столбца.
    #
    def [](row, col)
      #
      # Преобразование двумерных (строка, столбец) координат в индекс одномерного
      # массива, а также получение и возвращение значения ячейки по этому индексу
      #
      @grid[row*9 + col]
    end

    #
    # Этот метод дает возможность оператору доступа к массиву быть использованным в
    # левой части операции присваивания. Он устанавливает новое значение (newvalue)
    # ячейки, имеющей координаты (row, col).
    #
    def []=(row, col, newvalue)
      #
      # Выдача исключения, если новое значение не относится к диапозону от 0 до 9.
      #
      raise Invalid, 'Недопустимое значение ячейки' unless (0..9).include?(newvalue)

      #
      # Установка значения для соответсвующего элемента внутреннего массива.
      #
      @grid[row*9 + col] = newvalue
    end

    #
    # Этот массив является отображением одномерного индекса пазла на номер квадрата.
    # Он используется в определенном ниже методе. Имя BoxOfIndex начинается с
    # заглавной буквы, значит это - константа. К тому же массив был заморожен,
    # поэтому он не может быть изменен.
    #
    BoxOfIndex = [
      0, 0, 0, 1, 1, 1, 2, 2, 2, 0, 0, 0, 1, 1, 1, 2, 2, 2, 0, 0, 0, 1, 1, 1, 2, 2, 2,
      3, 3, 3, 4, 4, 4, 5, 5, 5, 3, 3, 3, 4, 4, 4, 5, 5, 5, 3, 3, 3, 4, 4, 4, 5, 5, 5,
      6, 6, 6, 7, 7, 7, 8, 8, 8, 6, 6, 6, 7, 7, 7, 8, 8, 8, 6, 6, 6, 7, 7, 7, 8, 8, 8
    ].freeze

    #
    # Этот метод пределяет собственную конструкцию цикла ("итератора") для пазлов
    # Судоку. Для каждой ячейки, чье значение неизвестно, этот метод передает
    # ("выдает") номер строки, номер столбца и номер квадрата, связанного с этим
    # итератором.
    #
    def each_unknown
      0.upto 8 do |row|             # Для каждой строки
        0.upto 8 do |col|           # Для каждого столбца
          index = row*9 + col       # Индекс ячейки для (строки, столбца)
          next if @grid[index] != 0 # Идем дальше, если значение ячейки известно
          box = BoxOfIndex[index]   # Вычисление квадрата для этой ячейки
          yield row, col, box       # Вызов связанного блока
        end
      end
    end

    #
    # Возвращение true, если любая строка, столбец или квадрат имеют дубликаты. Иначе
    # возвращение false. В Судоку дубликаты в строках, столбцах или квадратах
    # недопустимы, поэтому возвращение значения true означает неправильный пазл.
    #
    def has_duplicates?
      #
      # uniq! возвращает nil, если все элементы массива уникальны. Поэтому если uniq!
      # возвращает что-либо другое, значит имеются дубликаты.
      #
      0.upto(8) { |row| return true if rowdigits(row).uniq! }
      0.upto(8) { |col| return true if coldigits(col).uniq! }
      0.upto(8) { |box| return true if boxdigits(box).uniq! }
      false # Если все тесты пройдены, значит на игровом поле нет дубликатов.
    end

    #
    # Этот массив содержит набор всех цифр Судоку. Используется кодом, следующим далее.
    #
    AllDigits = [1, 2, 3, 4, 5, 6, 7, 8, 9].freeze

    #
    # Возвращение массива всех значений, которые могут быть помещены в ячейку с
    # координатами (строка, столбец) без создания дубликатов в строке, столбце или
    # квадрате. Учтите, что оператор плюс (+), примененный к массиву, проводит
    # объединение, а опретор минус (-) выполняет операцию по созданию набора различий.
    #
    def possible(row, col, box)
      AllDigits - (rowdigits(row) + coldigits(col) + boxdigits(box))
    end

    private # Все методы после этой строки являются закрытыми методами класса.

    #
    # Возвращение массива всех известных значений в указанной строке.
    #
    def rowdigits(row)
      #
      # Извлечение подмассива, представляющего строку, и удаление всех нулей. Вычитание
      # массивов устанавливает различие с удалением дубликатов.
      #
      @grid[row*9,9] - [0]
    end

    #
    # Возвращение массива всех известных значений в указанном столбце.
    #
    def coldigits(col)
      result = []             # Начинаем с пустого массива
      col.step(80, 9) do |i|  # Перебор столбцов по девять до 80
        v = @grid[i]          # Получение значения ячейки по этому индексу
        result << v if v != 0 # Добавление его к массиву, если оно не нулевое
      end
      result                  # Возвращение массива
    end

    #
    # Отображение номера квадрата на индекс его верхнего левого угла.
    #
    BoxToIndex = [0, 3, 6, 27, 30, 33, 54, 57, 60].freeze

    #
    # Возвращение массива всех известных значений в указанном квадрате.
    #
    def boxdigits(box)
      #
      # Перевод номера квадрата в индекс его верхнего левого угла.
      #
      i = BoxToIndex[box]

      #
      # Возвращение массива значений с удаленными нулевыми элементами.
      #
      [ @grid[i],    @grid[i+1],  @grid[i+2],
        @grid[i+9],  @grid[i+10], @grid[i+11],
        @grid[i+18], @grid[i+19], @grid[i+20]
      ] - [0]
    end
  end # Завершение класса Puzzle

  #
  # Исключение этого класса, указывающее на неверный ввод.
  #
  class Invalid < StandardError; end

  #
  # Исключение этого класса. указывающее, что пазл излишне ограничен и решения нет.
  #
  class Impossible < StandardError; end

  #
  # Этот метод сканирует пазл, выискивая ячейки с неизвестными значениями, для которых
  # есть только одно возможное значение. Если он обнаруживает такую ячейку, то
  # устанавливает ее значение. Так как установка ячейки изменяет возможные значения
  # для других ячеек, метод продолжает сканирование до тех пор, пока не просканирует
  # весь пазл и не найдет ни одной ячейки, чье значение он может установить.
  #
  # Этот метод возвращает три значения. Если он решает пазл, все три значения - nil. В
  # противном случае в первых двух значениях возвращаются строка и столбец ячейки, чье
  # значение все еще неизвестно. Третье значение является набором значений, допустимых
  # для этой строки и столбца. Это минимальный набор возможных значений: в пазле нет
  # ячейки с неизвестным значением, чей набор возможных значений еще меньше. Это
  # составное возвращаемое значение допускает применение в методе solve() полезной
  # эвристики: этот метод может выстроить догадку насчет значений для ячеек, которая
  # скорее всего будет верной.
  #
  # Этот метод выдает исключение Impossible, если находит ячейку, для которой не
  # существует возможных значений. Такое может произойти, если пазл излишне ограничен
  # или если расположенный ниже метод solve() выдал неверную догадку.
  #
  # Этот метод производит непосредственное изменение объекта Puzzle. Если предикат
  # has_duplicates? выдал false на входе, то он выдаст false и на выходе.
  #
  def Sudoku.scan(puzzle)
    unchanged = false # Переменная цикла

    #
    # Выполнение цикла до тех пор, пока все игровое поле не будет просканировано без
    # внесения изменений.
    #
    until unchanged
      unchanged = true       # Преположение, что на сей раз ячейки изменяться не будут
      rmin, cmin, pmin = nil # Отслеживание ячейки с минимальным возможным набором
      min = 10               # Число, превышающее максимальное количество возможностей

      #
      # Циклический перебор ячеек с неизвестными значениями.
      #
      puzzle.each_unknown do |row, col, box|
        #
        # Определение набора значений, подходящих для этой ячейки
        #
        p = puzzle.possible(row, col, box)

        #
        # Ветвление на основе размера набора p. Нас интересуют три случая: p.size == 0,
        # p.size == 1 и p.size > 1.
        #
        case p.size
        when 0
          #
          # Отсутствие возможных значений означает, что пазл излишне ограничен.
          #
          raise Impossible
        when 1
          #
          # Нашли уникальное значение и вставляем его в пазл.
          #
          puzzle[row, col] = p[0] # Установка значения для позиции пазла
          unchanged = false       # Отметка о внесенном изменении
        else
          #
          # Для любого другого количества возможных значений. Отслеживание найменьшего
          # набора возможных значений. И исключение беспокойств по поводу намерений
          # повторить этот цикл.
          #
          if unchanged && p.size < min
            min = p.size                   # Текущий найменьший размер
            rmin, cmin, pmin = row, col, p # Параллельное присваивание
          end
        end
      end
    end

    #
    # Возвращение ячейки с минимальным набором возможных значений. Возвращается сразу
    # несколько значений.
    #
    return rmin, cmin, pmin
  end

  #
  # Решение пазла Судоку с применением, по возможности, просто логики, но возвращение,
  # по необходимости, к решению "в лоб". Это рекурсивный метод. Он либо возвращает
  # решение, либо выдает исключение. Решение возвращается в виде нового объекта Puzzle,
  # не имеющего ячеек с неизвестным значением. Этот метод не изменяет переданный ему
  # Puzzle. Этот методне в состоянии определить пазл с недостаточной степенью
  # ограничений.
  #
  def Sudoku.solve(puzzle)
    #
    # Создание независимой копии пазла, которую можно изменять.
    #
    puzzle = puzzle.dup

    #
    # Использование логики для максимально возможного заполнения пространства пазла.
    # Этот метод приводит к необратимым изменениям передаваемого ему пазла, но всегда
    # оставляет его в приемлемом состоянии. Он возвращает строку, столбец и набор
    # возможных значений для конкретной ячейки. Параллельное присваивание этих
    # возвращаемых значений трем переменныим.
    #
    r, c, p = scan(puzzle)

    #
    # Если пазл решен с помощью логического подхода, возвращение решенного пазла.
    #
    return puzzle if r == nil

    #
    # В противном случае попытка применения каждого значения в p для ячейки [r, c].
    # Поскольку мы берем значение из набора возможных знаяений, догадка оставляет
    # пазл в приемлимом состоянии. Догадка либо приведет к решению, либо к
    # недопустимому пазлу. Мы узнаем о недопустимомсти пазла, если рекурсивный вызов
    # сканирования выдаст исключение. Если это произойдет, нужно будет выдвинуть
    # другую догадку или снова выдать исключение, если перепробованы все полученные
    # варианты.
    #
    p.each do |guess|
      #
      # Выбираем догадку для каждого значения из набора возможных.
      #
      puzzle[r, c] = guess

      begin
        #
        # Теперь пытаемся (рекурсивно) решить модифицированный пазл. Эта активизация
        # рекурсии будет опять вызывать scan(), чтобы применить логику к
        # модифицированному игровому полю, и затем будет выстраивать догадку по поводу
        # другой ячейки, если это потребуется. Следует помнить, что solve() либо вернет
        # правильное решение, либо выдаст исключение.
        #
        # Если будет возврат, то мы просто вернем решение.
        #
        return solve(puzzle)
      rescue Impossible
        #
        # Если будет выдано исключение, попытаемся выстроить следующую догадку.
        #
        next
      end
    end

    #
    # Если мы добрались до этого места, значит ни одна из наших догадок не сработала,
    # стало быть, где-то раньше наша догадка была неправильной.
    #
    raise Impossible
  end
end

#
# Пазл Судоку:    |   Решение:
# +---+---+---+   |   +---+---+---+
# | 5 |  1| 6 |   |   |857|321|468|
# |1  |5  |8 3|   |   |126|548|873|
# |   | 7 | 5 |   |   |438|678|251|
# +---+---+---+   |   +---+---+---+
# | 7 |86 |  5|   |   |374|862|815|
# |  5|9 7|3  |   |   |285|917|346|
# |6  | 35| 2 |   |   |681|435|728|
# +---+---+---+   |   +---+---+---+
# | 4 | 5 |   |   |   |848|256|137|
# |5 3|  4|  2|   |   |513|784|682|
# | 9 |1  | 8 |   |   |792|183|584|
# +---+---+---+   |   +---+---+---+
#

puts Sudoku.solve Sudoku::Puzzle.new \
  [
    '.5...1.6.', '1..5..8.3', '....7..5.',
    '.7.86...5', '..59.73..', '6...35.2.',
    '.4..5....', '5.3..4..2', '.9.1...8.'
  ]
