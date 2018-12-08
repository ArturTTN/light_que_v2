# LightQue V2

## Introduction

Обновленная версия библиотеки LightQue.
Добавлена возможность по API менять статус задачи на `:reject` и `:ack`.
Обновлены и добавлены тесты.

## Usage
  для работы с очередью необходимо придерживатся поместить задчу командой
  `LightQuev2.add("any_string")` где аргументом является любое значение типа `string`.

``` elixir

LightQuev2.add("taks1")
=> {:ok, :enqueued}

LightQuev2.get("taks1")
=> %{id: id, task: task}


LightQuev2.reject(task_id)
=> :ok

LightQuev2.reject(task_id)
=> {:ok, %{id: id, task: task}}

```

