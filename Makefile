#
# Makefile
# Peter Lau, 2021-05-25 14:04
#

all:
	make get

# vim:ft=make


.PHONY: dev cli routes

dev:
	mix phx.server

cli:
	iex -S mix phx.server

routes:
	mix phx.routes

get:
	mix deps.get

migrate:
	mix ecto.migrate

seed:
	mix run priv/repo/seeds.exs

start:
	iex -S mix run

nostart:
	iex -S mix run --no-start

recreate:
	mix do ecto.drop, ecto.create

test-migrate:
	MIX_ENV=test mix ecto.migrate

test-seed:
	MIX_ENV=test mix run priv/repo/seeds.exs

test-start:
	MIX_ENV=test iex -S mix run

test-nostart:
	MIX_ENV=test iex -S mix run --no-start

test-recreate:
	MIX_ENV=test mix do ecto.drop, ecto.create
