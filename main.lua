function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Minesweeper")
    MineSweeperFont = love.graphics.newFont("mine-sweeper.ttf")
    love.graphics.setFont(MineSweeperFont)
    Width,Height,Flags=love.window.getMode()
    MenuBackground=love.graphics.newImage("assets/menuBackground.png")
    Banner=love.graphics.newImage("assets/bannerGoodGame.png")
    PlayButton=love.graphics.newImage("assets/playLittleButton.png")
    PlayButtonX=306
    PlayButtonY=124
    QuitButton=love.graphics.newImage("assets/quitLittleButton.png")
    QuitButtonX=306
    QuitButtonY=374
    MineCube=love.graphics.newImage("assets/MineCube.png")
    MineCubeTrapped=love.graphics.newImage("assets/MineCubeTrapped.png")
    MineCubeClear=love.graphics.newImage("assets/MineCubeClear.png")
    MineCubeFlag=love.graphics.newImage("assets/MineCubeFlag.png")
    MineCubeTrappedFlag=love.graphics.newImage("assets/MineCubeTrappedFlag.png")
    Text1=love.graphics.newImage("assets/text1.png")
    Text2=love.graphics.newImage("assets/text2.png")
    Text3=love.graphics.newImage("assets/text3.png")
    Text4=love.graphics.newImage("assets/text4.png")
    Text5=love.graphics.newImage("assets/text5.png")
    Text6=love.graphics.newImage("assets/text6.png")
    Text7=love.graphics.newImage("assets/text7.png")
    Text8=love.graphics.newImage("assets/text8.png")
    RestartText=love.graphics.newImage("assets/restartText.png")
    RestartTextX=45
    RestartTextY=427
    YouLose=love.graphics.newImage("assets/youLoseText.png")
    YouLoseX=233
    YouLoseY=274
    YouWin=love.graphics.newImage("assets/youWinText.png")
    YouWinX=251
    YouWinY=274
    GameLost=false
    GameWin=false
    MineNumber=math.floor(16*11*0.175)
    MineField=CreateMinefield(16,11)
    TimeMinus=0
    InMenu=true
    InGame=false
end

function TableContains(table,value)
    for i = 1, #table, 1 do
        if table[i]==value then
            return true
        end
    end
    return false
end

function CleanMineField(tableMinefield)
    for i = 1, #tableMinefield, 1 do
        for j = 1, #tableMinefield[1],1 do
            if CountBombAround(tableMinefield,i,j)==0 then
                tableMinefield[i][j]=MineCubeClear
                for k = i-1,i+1,1 do
                    for l =j-1,j+1,1 do
                        if k>0 and l>0 and k<#tableMinefield+1 and l<#tableMinefield[1]+1 then
                            local bombNumber=CountBombAround(tableMinefield,k,l)
                            if bombNumber==0 then
                                tableMinefield[k][l]=MineCubeClear
                            elseif bombNumber==1 then
                                tableMinefield[k][l]=Text1
                            elseif bombNumber==2 then
                                tableMinefield[k][l]=Text2
                            elseif bombNumber==3 then
                                tableMinefield[k][l]=Text3
                            elseif bombNumber==4 then
                                tableMinefield[k][l]=Text4
                            elseif bombNumber==5 then
                                tableMinefield[k][l]=Text5
                            elseif bombNumber==6 then
                                tableMinefield[k][l]=Text6
                            elseif bombNumber==7 then
                                tableMinefield[k][l]=Text7
                            elseif bombNumber==8 then
                                tableMinefield[k][l]=Text8
                            end
                        end
                    end
                end
            end
        end
    end
    return tableMinefield
end

function CreateMinefield(widthMinefield,heightMinefield)
    local counter=1
    local matrix = {}
    for i = 1, heightMinefield, 1 do
        matrix[i]={}
        for j = 1, widthMinefield, 1 do
            matrix[i][j]=counter
            counter = counter + 1
        end
    end
    local tableMine={}
    for i = 1, MineNumber, 1 do
        local mineLocation=matrix[math.random(#matrix)][math.random(#matrix[1])]
        while (TableContains(tableMine,mineLocation)) do
            mineLocation=matrix[math.random(#matrix)][math.random(#matrix[1])]
        end
        tableMine[i]=mineLocation
    end
    local tableMinefield={}
    for i = 1, heightMinefield, 1 do
        tableMinefield[i]={}
        for j = 1, widthMinefield, 1 do
            if TableContains(tableMine,matrix[i][j]) then
                tableMinefield[i][j]=MineCubeTrapped
            else
                tableMinefield[i][j]=MineCube
            end
        end
    end
    tableMinefield=CleanMineField(tableMinefield)
    return tableMinefield
end

function CountBombAround(mineField,row,column)
    local bombNumber=0
    for i = row-1, row+1, 1 do
        for j = column-1, column+1, 1 do
            if i>0 and i<12 and j>0 and j<17 then
                if mineField[i][j]==MineCubeTrapped or mineField[i][j]==MineCubeTrappedFlag then
                    bombNumber = bombNumber + 1
                end
            end
        end
    end
    return bombNumber
end

function CountBombAroundMouse(mineField,xMouse,yMouse)
    local bombNumber=0
    local rowMineCube=math.floor(yMouse/50)
    local columnMineCube=math.floor(xMouse/50)+1
    for i = rowMineCube-1, rowMineCube+1, 1 do
        for j = columnMineCube-1, columnMineCube+1, 1 do
            if i>0 and i<12 and j>0 and j<17 then
                if mineField[i][j]==MineCubeTrapped or mineField[i][j]==MineCubeTrappedFlag then
                    bombNumber = bombNumber + 1
                end
            end
        end
    end
    return bombNumber
end

function AllBombFound(mineField)
    local bombNumber=0
    local mineCubeNumber=0
    for i = 1, #mineField, 1 do
        for j = 1, #mineField[1], 1 do
            if mineField[i][j]==MineCubeTrapped then
                bombNumber = bombNumber + 1
            elseif mineField[i][j]==MineCube then
                mineCubeNumber = mineCubeNumber + 1
            end
        end
    end
    if bombNumber==0 or mineCubeNumber==0 then
        return true
    else
        return false
    end
end

function love.update(dt)
    Time=math.floor(love.timer.getTime())-TimeMinus
    if GameLost then
        Banner=love.graphics.newImage("assets/bannerDeadGame.png")
    else
        Banner=love.graphics.newImage("assets/bannerGoodGame.png")
    end
    if AllBombFound(MineField) then
        GameWin=true
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end
    if key == "r" then
        MineNumber=math.floor(16*11*0.175)
        TimeMinus=TimeMinus+Time
        MineField=CreateMinefield(16,11)
        GameLost=false
        GameWin=false
    end
end

function love.mousepressed(x,y,button)
    if not GameLost then
        if InMenu then
            if button==1 and x>PlayButtonX and x<PlayButtonX+PlayButton:getWidth() and y>PlayButtonY and y<PlayButtonY+PlayButton:getHeight() then
                InGame=true
                InMenu=false
                TimeMinus=TimeMinus+Time
            end
            if button==1 and x>QuitButtonX and x<QuitButtonX+QuitButton:getWidth() and y>QuitButtonY and y<QuitButtonY+QuitButton:getHeight() then
                love.event.quit()
            end
        else
            if button==1 and y>Banner:getHeight() then
                local rowMineCubeClicked=math.floor(y/50)
                local columnMineCubeClicked=math.floor(x/50)+1
                if MineField[rowMineCubeClicked][columnMineCubeClicked]==MineCube then
                    local numberBombAround=CountBombAroundMouse(MineField,x,y)
                    if numberBombAround==0 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=MineCubeClear
                    elseif numberBombAround==1 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text1
                    elseif numberBombAround==2 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text2
                    elseif numberBombAround==3 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text3
                    elseif numberBombAround==4 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text4
                    elseif numberBombAround==5 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text5
                    elseif numberBombAround==6 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text6
                    elseif numberBombAround==7 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text7
                    elseif numberBombAround==8 then
                        MineField[rowMineCubeClicked][columnMineCubeClicked]=Text8
                    end
                elseif MineField[rowMineCubeClicked][columnMineCubeClicked]==MineCubeTrapped then
                    GameLost=true
                end
            elseif button==2 and y>Banner:getHeight() then
                local rowMineCubeClicked=math.floor(y/50)
                local columnMineCubeClicked=math.floor(x/50)+1
                if MineField[rowMineCubeClicked][columnMineCubeClicked]==MineCube and MineNumber>0 then
                    MineField[rowMineCubeClicked][columnMineCubeClicked]=MineCubeFlag
                    MineNumber = MineNumber - 1
                elseif MineField[rowMineCubeClicked][columnMineCubeClicked]==MineCubeTrapped and MineNumber>0 then
                    MineField[rowMineCubeClicked][columnMineCubeClicked]=MineCubeTrappedFlag
                    MineNumber = MineNumber - 1
                elseif MineField[rowMineCubeClicked][columnMineCubeClicked]==MineCubeFlag then
                    MineField[rowMineCubeClicked][columnMineCubeClicked]=MineCube
                    MineNumber = MineNumber + 1
                elseif MineField[rowMineCubeClicked][columnMineCubeClicked]==MineCubeTrappedFlag then
                    MineField[rowMineCubeClicked][columnMineCubeClicked]=MineCubeTrapped
                    MineNumber = MineNumber + 1
                end
            end
        end
    end
end

function Draw_menu()
    love.graphics.draw(MenuBackground,0,50)
    love.graphics.draw(Banner)
    love.graphics.draw(PlayButton,PlayButtonX,PlayButtonY)
    love.graphics.draw(QuitButton,QuitButtonX,QuitButtonY)
end

function Draw_game()
    love.graphics.draw(Banner)
    for j = 1, #MineField, 1 do
        for i = 1, #MineField[1], 1 do
            Img=MineField[j][i]
            love.graphics.draw(Img,(i-1)*50,j*50,0,0.5,0.5) --16 longueur 11 hauteur
        end
    end
    if GameLost then
        love.graphics.draw(YouLose,YouLoseX,YouLoseY)
    elseif GameWin then
        love.graphics.draw(YouWin,YouWinX,YouWinY)
    end
    if not GameLost and not GameWin then
        love.graphics.setColor(0,0,0)
        love.graphics.print("Temps "..Time,10,10)
        love.graphics.print("Mines restantes : "..MineNumber,Width-235,10)
        love.graphics.setColor(255,255,255)
    else
        love.graphics.draw(RestartText,RestartTextX,RestartTextY)
    end
end

function love.draw()
    if InMenu then
        Draw_menu()
    end
    if InGame then
        Draw_game()
    end
end