::------------------------------------------------------------------------------
:: Something that vaguely resembles a stock market simulator except not really.
::
:: Earn $2.1 billion to win. (And by win, I mean cause an integer overflow.)
:: Theoretically, the game can be won in 8 transactions. Personally, I usually
:: finish in 18-20.
::
:: Based on http://www.kongregate.com/games/GazThomas/tangerine-tycoon
::------------------------------------------------------------------------------
@echo off
setlocal enabledelayedexpansion
cls

::------------------------------------------------------------------------------
:: VARIABLE INITIALIZATION
::------------------------------------------------------------------------------
set transfer_count=0
set money=50

for /l %%A in (1,1,5) do (
		set stock_count[%%A]=0
		set "stock_action[%%A]=BUY "
)

::------------------------------------------------------------------------------
:: MAIN GAME
::------------------------------------------------------------------------------
:market_change
cls

:: Batch uses signed 32-bit integers, so the maximum number is 2147483647
:: Go higher than that, and the number will go negative
if !money! geq 2100000000 goto :maxed_out
if !money! lss 0 goto :maxed_out

:: Stock prices randomly fluctuate between $1 and $100
:: For those of you learning batch from this particular script, that ^ is there
:: so that the for loop doesn't think the ) that comes right after it is the one
:: that terminates the loop.
for /l %%A in (1,1,5) do (
	set /a stock_price[%%A]=(!random! %% 100^) + 1
)

:: Display the main screen
echo(Money: $!money!
echo/
echo(Generic Stock A: !stock_price[1]!	(!stock_count[1]!)
echo(Generic Stock B: !stock_price[2]!	(!stock_count[2]!)
echo(Generic Stock C: !stock_price[3]!	(!stock_count[3]!)
echo(Generic Stock D: !stock_price[4]!	(!stock_count[4]!)
echo(Generic Stock E: !stock_price[5]!	(!stock_count[5]!)
echo/
echo([1] - !stock_action[1]! half of A ^| [6] - !stock_action[1]! all of A
echo([2] - !stock_action[2]! half of B ^| [7] - !stock_action[2]! all of B
echo([3] - !stock_action[3]! half of C ^| [8] - !stock_action[3]! all of C
echo([4] - !stock_action[4]! half of D ^| [9] - !stock_action[4]! all of D
echo([5] - !stock_action[5]! half of E ^| [0] - !stock_action[5]! all of E
:: Get user input
choice /C:1234567890NQ /N /T 2 /D N >nul
if !errorlevel! lss 11 call :transfer !errorlevel!
if !errorlevel! equ 11 goto :market_change
if !errorlevel! equ 12 echo(You made !transfer_count! transfers before quitting. & exit /b
goto :market_change

::------------------------------------------------------------------------------
:: TRANSFER SUBROUTINE
::
:: In BUY mode, spend either half or all of your money on a stock
:: In SELL mode, sell 100% of that stock
::
:: Arguments: %1 - the index (or index+5) or the stock to transfer
:: Returns:   None
::------------------------------------------------------------------------------
:transfer
set /a transfer_count+=1
if %~1 geq 6 (
	set /a stock_index=%~1-5
	set half_or_all=1
) else (
	set stock_index=%~1
	set half_or_all=2
)

:: This is the lazy way to get nested delayed expansion
for /f %%A in ("!stock_index!") do (
	if "!stock_action[%%A]!"=="BUY " (
		set /a stock_count[%%A]=(!money!/!stock_price[%%A]!^)/!half_or_all!
		set /a buy_price=!stock_price[%%A]!*!stock_count[%%A]!
		set /a money-=!buy_price!
		set "stock_action[%%A]=SELL"
	) else (
		set /a adjusted_stock_count=!stock_count[%%A]!/!half_or_all!
		if !stock_count[%%A]! equ 1 set adjusted_stock_count=1
		set /a get_price=!stock_price[%%A]!*!adjusted_stock_count!
		set /a money+=!get_price!
		set /a stock_count[%%A]-=!adjusted_stock_count!
		set "stock_action[%%A]=BUY "
	)
)
goto :eof

::------------------------------------------------------------------------------
:: END GAME
::------------------------------------------------------------------------------
:maxed_out
echo(You have reached your goal of $2.1 billion^^!
echo(It took you !transfer_count! transfers.
pause